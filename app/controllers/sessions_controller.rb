class SessionsController < ApplicationController
@@user = nil

def new
  redirect_to '/auth/reddit'
end

def create
  auth = request.env["omniauth.auth"]
  
  @@user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
  session[:user_id] = @@user.id
  @@user.oauth_token = auth["code"]
  @@user.save!
  raise request.env["omniauth.params"].to_yaml   
  redirect_to root_url, :notice => "Signed in!"
end

def access
  uri = URI.parse("https://ssl.reddit.com")
  http = Net::HTTP.new(uri.host, uri.port)
  params = { :scope => 'identity,mysubreddits,history',
             :client_id => RCONFIG['app_id'],
             :redirect_uri => 'http://localhost:3000/auth/reddit/callback',
             :code => @@user.oauth_token,
             :grant_type => 'authorization_code'
             }
  request = Net::HTTP::Post.new("/api/v1/access_token")
  request.set_form_data(params)
  request.basic_auth(RCONFIG['app_id'],RCONFIG['secret'])
  response = http.request(request)
  redirect_to root_url, :notice => "access permitted"
end

def destroy
  session[:user_id] = nil
  redirect_to root_url, :notice => "Signed out!"
end

def failure
  redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
end

end
