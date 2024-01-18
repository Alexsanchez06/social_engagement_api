Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  if ActiveRecord::Base.connection.table_exists? AppConfig.table_name && AppConfig.first.present?
   twitter_credentials = AppConfig.first
   provider :twitter, twitter_credentials.twitter_api_key, twitter_credentials.twitter_api_secret
  else
    provider :twitter, Rails.application.credentials.twitter.api_key, Rails.application.credentials.twitter.api_secret
  end
end

OmniAuth.config.logger = Rails.logger
