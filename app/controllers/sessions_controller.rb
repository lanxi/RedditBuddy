class SessionsController < ApplicationController
@@token  = ""
@@currID = ""
@@favRedditors = {}

def new
  redirect_to '/auth/reddit'
end

def create
  auth = request.env["omniauth.auth"]
  
  user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
  session[:user_id] = user.id
  user.oauth_token = auth["credentials"]["token"].to_str
  user.save!  
  @@token = auth["credentials"]["token"].to_str
  @@currID = user.name
  redirect_to root_url, :notice => "Signed in!"
end

def access
  uri = URI.parse("https://oauth.reddit.com")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  headers = { "Authorization" => "bearer "+@@token }
  liked = "/user/"+@@currID+"/liked"
  
  response, data = http.get2(liked,headers)
  resp_body = JSON.parse(response.body)
  resp_likes = resp_body["data"]["children"]
  resp_likes.each do |x|
    if @@favRedditors.has_key?(x["data"]["author"])
	weight = @@favRedditors[x["data"]["author"]] + 1
	@@favRedditors[x["data"]["author"]] = weight
    else
	@@favRedditors[x["data"]["author"]] = 1
    end
  end
  direct_to root_url  
end

def destroy
  session[:user_id] = nil
  redirect_to root_url, :notice => "Signed out!"
end

def failure
  redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
end

end
