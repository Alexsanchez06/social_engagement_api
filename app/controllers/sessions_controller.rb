class SessionsController < ApplicationController

  def authenticate    
    if params[:provider] == Social::Twitter::SOCIAL_TYPE
      redirect_to "/auth/twitter?state=#{params[:api_token]}", allow_other_host: true
      return
    end
  end

  def create
    if params[:state].blank?
      render json: { success: false, message: 'Invalid Authentication' }
      return
    end

    auth = request.env['omniauth.auth']

    user = User.find_or_create_by_auth(auth, params[:state])

    if user
      base_url = URI(AppConfig.ui_host)
      base_url.query = URI.encode_www_form({
        auth_success: true,
        provider: 'twitter',
        token: params[:state],
        username: user.username
      })
      
      redirect_to(base_url.to_s, allow_other_host: true)
      return      
    end
  end

  def reverify_authentication
    
    token = decoded_token(params[:token]).deep_symbolize_keys rescue nil
    user = token && User.find_by(username: token[:username], auth_reference: token[:api_token])
    unless user
      render json: {
        success: false,
        error: "Unable to verify authentication"
      }
      return
    end

    if params[:provider] == Social::Twitter::SOCIAL_TYPE
      render json: {
        success: true,
        data: {
          id: user.id,
          username: user.username,
          display_name: user.display_name,
          image: user.meta_data&.dig('extra', 'raw_info', 'profile_image_url_https')
        }
      }
    end
  end

  def verify_authentication
    user = User.find_by(username: params[:username], auth_reference: params[:api_token])        
    unless user
      render json: {
        success: false,
        error: "Unable to verify authentication"
      }
      return
    end

    if params[:provider] == Social::Twitter::SOCIAL_TYPE

      token = encode_token({
        username: user.username,
        api_token: params[:api_token]
      })

      response.set_header('Authorization', "Bearer #{token}")

      render json: {
        success: true,
        access_token: token,
        data: {
          id: user.id,
          username: user.username,
          display_name: user.display_name,
          image: user.meta_data&.dig('extra', 'raw_info', 'profile_image_url_https')
        }
      }
    end
  end

end
