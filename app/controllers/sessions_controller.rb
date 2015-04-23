class SessionsController < ApplicationController
  @@token  = ""
  @@currID = ""
  @@favRedditors = {}
  @@karma = {}
  @@favSubreddits = {}

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
    # get fav users (sorted)
    uri = URI.parse("https://oauth.reddit.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    headers = { "Authorization" => "bearer "+@@token }

    #/user/username/liked
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
    fav_users = @@favRedditors.sort_by{|name, value| value}.reverse!
    @names = ""
    count = 0
    fav_users.each {|val| 
      if count < 10
        @names+=(val[0]+",")
        count += 1
      end
    }
    @names = @names[0..-2]

    #/api/v1/me/karma 
    karma = "/api/v1/me/karma"
    response, data = http.get2(karma,headers)
    resp_body = JSON.parse(response.body)
    puts resp_body
    resp_karma = resp_body["data"]
    total_karma = 0
    resp_karma.each do |x|
      weight = x["comment_karma"].to_i + x["link_karma"].to_i
      @@karma[x["sr"]] = weight
      total_karma += weight
    end
    fav_karma = @@karma.sort_by{|name, value| value}.reverse!
    @karma = fav_karma.to_s
    #parse list of subreddit (<=top10) and access db to find most matched redditors 

    #/user/username/submitted
    submitted = "/user/"+@@currID+"/submitted"
    response, data = http.get2(submitted,headers)
    resp_body = JSON.parse(response.body)
    #parse resp_body
    resp_submitted = resp_body["data"]["children"]
    resp_submitted.each do |x|
      if @@favSubreddits.has_key?(x["data"]["subreddit"])
        weight = @@favSubreddits[x["data"]["subreddit"]] + 1
        @@favSubreddits[x["data"]["subreddit"]] = weight
      else
        @@favSubreddits[x["data"]["subreddit"]] = 1
      end
    end

    #/user/username/comments
    comments = "/user/"+@@currID+"/comments"
    response, data = http.get2(comments,headers)
    resp_body = JSON.parse(response.body)
    #parse resp_body
    resp_comments = resp_body["data"]["children"]
    resp_comments.each do |x|
      if @@favSubreddits.has_key?(x["data"]["subreddit"])
        weight = @@favSubreddits[x["data"]["subreddit"]] + 1
        @@favSubreddits[x["data"]["subreddit"]] = weight
      else
        @@favSubreddits[x["data"]["subreddit"]] = 1
      end
    end
    fav_Subreddits = @@favSubreddits.sort_by{|name, value| value}.reverse!
    @subreddits = fav_Subreddits.to_s

    session[:subreddits] = @subreddits
    session[:names] = @names
    session[:karma] = @karma
    redirect_to help_path, :notice => "Got favs!" 
  end

  def match
    fav_Subreddits = @@favSubreddits.sort_by{|name, value| value}.reverse!
    # loop through fav, find top 100 or max from each and count the score, rank and spit top 20
    match_count = {}

    fav_Subreddits.each do |name, score|
      subreddit = Subreddit.find_by_name(name)
      redditors = Redditor.find_by_subreddit_id(subreddit)
      raise redditors.to_s
      redditors.each do |x|
        if match_count.has_key?(x.name)
          weight = match_count[x.name] + x.score
          match_count[x.name] = weight
        else
          match_count[x.name] = x.score
        end
      end
    end

    match_count_sort = match_count.sort_by{|name, value| value}.reverse!
    count = 0
    @match = ""
    match_count_sort each do |name, score|
      if count < 20
        @match += (name+",")
        count += 1
      end
    end
    
    session[:match] = @match
    redirect_to match_path, :notice => "Got matches!" 
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
