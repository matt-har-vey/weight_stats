class ApplicationController < ActionController::Base
  layout 'main'

  protect_from_forgery

  before_filter :set_csp

  def set_csp
    response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self' 'unsafe-inline'"
  end

  def authorized?
    !session[:access_token].nil? && !session[:fitbit_id].nil?
  end

  def authorize(next_url)
    request_token = FitBit::CONSUMER.get_request_token(:oauth_callback => auth_url)
    flash[:next_url] = next_url
    session[:request_token] = request_token
    redirect_to request_token.authorize_url
  end
end
