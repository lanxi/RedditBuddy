OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :reddit, RCONFIG['app_id'], RCONFIG['secret'], :scope => 'identity,mysubreddits,history'
end