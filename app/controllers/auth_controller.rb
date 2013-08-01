class AuthController < ApplicationController
  def callback
    session[:access_token] = session[:request_token].get_access_token(
      :oauth_verifier => params[:oauth_verifier])
    redirect_to flash[:next_url]
  end

  def logout
    reset_session
    render
  end
end
