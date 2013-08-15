class ApplicationController < ActionController::Base
  layout 'main'

  protect_from_forgery

  before_filter :set_csp, :set_time_zone, :user_required

  private
    def set_csp
      response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self' 'unsafe-inline'"
    end

    def set_time_zone
      Time.zone = 'Pacific Time (US & Canada)'
    end

    def user_required
      unless authorized?
        reset_session
        authorize
        false
      end
    end

    def authorized?
      !session[:user_id].nil?
    end

    def authorize
      request_token = Fitbit::CONSUMER.get_request_token(:oauth_callback => auth_url)
      flash[:request_token] = request_token
      redirect_to request_token.authorize_url
    end
end
