class ApplicationController < ActionController::Base
  layout 'main'

  protect_from_forgery

  before_filter :set_csp, :set_time_zone

  private
    def set_csp
      response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self' 'unsafe-inline'"
    end

    def set_time_zone
      Time.zone = 'Pacific Time (US & Canada)'
    end

    def authorized?
      !session[:user_id].nil?
    end

    def authorize(next_url)
      request_token = FitBit::CONSUMER.get_request_token(:oauth_callback => auth_url)
      flash[:next_url] = next_url
      flash[:request_token] = request_token
      redirect_to request_token.authorize_url
    end

    def user
      @user ||= (session[:user_id] && User.find(session[:user_id]))
    end
end
