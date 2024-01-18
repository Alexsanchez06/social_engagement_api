class AppConfig < ApplicationRecord
  
  def self.instance
    @@instance ||= AppConfig.first
  end

  def self.update_configuration(conf_params)
  	app_conf = AppConfig.first
    app_conf.update_columns(twitter_client_id: conf_params[:twitter_client_id],
                            twitter_client_secret: conf_params[:twitter_client_secret],
                            twitter_auth_token: conf_params[:twitter_auth_token],
                            twitter_api_key: conf_params[:twitter_api_key],
                            twitter_api_secret: conf_params[:twitter_api_secret],
                            twitter_tags: conf_params[:twitter_tags],
                            admin_user: conf_params[:admin_user],
                            is_enable_claim_notification: conf_params[:enable_claim_notification],
                            is_coming_soon: conf_params[:coming_soon],
                            is_enable_login: conf_params[:enable_login],
                            is_enable_claim: conf_params[:enable_claim])
    app_conf
  end

  def self.twitter_api_key
    self.instance&.twitter_api_key    
    # Rails.application.credentials.twitter.api_key
  end

  def self.twitter_api_secret
  	self.instance&.twitter_api_secret
    # Rails.application.credentials.twitter.api_secret
  end

  def self.twitter_auth_token
  	self.instance&.twitter_auth_token
    # Rails.application.credentials.twitter.auth_token
  end

  def self.schedule_interval
    Rails.application.credentials.schedule_interval
  end

  def self.batch_size
    Rails.application.credentials.batch_size.to_i
  end

  def self.twitter_tags
  	self.instance&.twitter_tags.strip.split(/\s*,\s*/)
    # Rails.application.credentials.twitter_tags.strip.split(/\s*,\s*/)
  end

  def self.admin_user
  	self.instance&.admin_user
    # Rails.application.credentials.admin_user
  end

  def self.ui_host
    Rails.application.credentials.ui_host
  end

  def self.jwt_secret_key
    Rails.application.credentials.jwt_secret_key
  end

  def self.login_expiry_time
    Rails.application.credentials.login_expiry_time.to_i
  end

  # -- Cache --
  def self.cache_time
    Rails.application.credentials.cache_time.to_i
  end

  def self.enable_sync
    Rails.application.credentials.enable_sync
  end

  # -- DB --
  def self.db_host
    Rails.application.credentials.database.host
  end
  
  def self.db_name
    Rails.application.credentials.database.name
  end

  def self.db_username
    Rails.application.credentials.database.username
  end

  def self.db_password
    Rails.application.credentials.database.password
  end

  # private_key
  # public_address
  # rpc
  # explorer
  # credits_ratio
  def self.network(name)
    Rails.application.credentials.network[name.intern]
  end
end
