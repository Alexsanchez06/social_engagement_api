class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection  

  rescue_from StandardError, with: :handle_exception
  rescue_from ActiveRecord::RecordInvalid, with: :show_record_errors
  rescue_from ActiveRecord::RecordNotFound, with: :record_notfound_errors


  def handle_exception(exception)
    # Handle exceptions and render a generic JSON response
    error_message = exception.message || 'An error occurred'
    logger.error exception.class
    logger.error exception.backtrace.join("\n")

    render json: { 
      success: false,
      error: error_message 
      }, status: :bad_request
  end

  def show_record_errors(exception)
    # Handle exceptions and render a generic JSON response
    error_message = exception.message || 'An error occurred'
    logger.error exception

    render json: { 
      success: false,
      error: error_message 
      }, status: :unprocessable_entity
  end

  def record_notfound_errors(exception)
    error_message = exception.message || 'An error occurred'
    logger.error exception

    render json: { 
      success: false,
      error: error_message 
      }, status: :not_found
  end

  def success_failure
    data = Reward.calculate_success_failure(params[:id])

    respond_with data
  end

  def export
    csv_data = Reward.to_csv
    send_data(csv_data, filename: "Airdrop_Full_Stats_#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}.csv", type: :csv)
  end

  def get_app_config
    app_config = AppConfig.first

    data = {
     twitter_client_id: app_config.twitter_client_id,
     twitter_client_secret: app_config.twitter_client_secret,
     twitter_auth_token: app_config.twitter_auth_token,
     twitter_api_key: app_config.twitter_api_key,
     twitter_api_secret: app_config.twitter_api_secret,
     twitter_tags: app_config.twitter_tags,
     admin_user: app_config.admin_user,
     enable_claim_notification: app_config.is_enable_claim_notification,
     coming_soon: app_config.is_coming_soon,
     enable_login: app_config.is_enable_login,
     enable_claim: app_config.is_enable_claim
    }
    respond_with data
  end

  def update_app_config
    data = AppConfig.update_configuration(params)
    restart_pm2_services
    respond_with data
  end

  def restart_pm2_services
    result = `pm2 restart all`
    #sidekiq_result = `pm2 restart Sidekiq`
    puts "PM2 Restart Result: #{result}"
  end

  def create_airdrop
    data = Epoch.create_epoch(params)
    respond_with data
  end

  def live_airdrop
    data = Epoch.unscoped.all.desc
    respond_with data
  end

  def delete_airdrop
    data = Epoch.delete_epoch(params[:id])
    respond_with data
  end

  def stats
    data = cached_data(Cache.stats_key) do 
      Epoch.stats 
    end

    respond_with data
  end

  def full_stats
    data = cached_data(Cache.full_stats_key) do 
      Epoch.full_stats
    end

    respond_with data
  end
  
  def leader_board
    data = cached_data(Cache.leader_board_key) do 
      Epoch.leader_board
    end

    respond_with data
  end

  def load_user
    return unless params[:id]
    @current_user = User.find_by(id: params[:id])
    raise "User not found" unless params[:id] && @current_user
    @epoch = Epoch.live
  end

  def clear_cache            
    render json: { success: Rails.cache.delete(params[:key]&.strip) }
  end

  protected

  def respond_with(data, status = :ok)
    render json: {
      success: status == :ok, 
      data:
      }, status: status
  end

  def cached_data(key)
    data = yield
  
    # Check if the data is not empty or nil before caching
    if data.present?
      Rails.cache.fetch(key, expires_in: AppConfig.cache_time.hour) do
        data
      end
    else
      data
    end
  end

  private
  def encode_token(payload, exp = AppConfig.login_expiry_time.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.jwt_secret_key, 'HS256')
  end

  def decoded_token(token)
    token ||= request.headers['Authorization'].split(' ')[1]
    JWT.decode(token, Rails.application.credentials.jwt_secret_key, true, algorithm: 'HS256')[0]
  end
end
