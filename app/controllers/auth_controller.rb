class AuthController < ApplicationController
  def callback
    session[:access_token] = session[:request_token].get_access_token(
      :oauth_verifier => params[:oauth_verifier])

    user = User.find_or_create_authorized(session[:access_token])
    session[:fitbit_id] = user.fitbit_id
    session[:user_id] = user.id

    redirect_to flash[:next_url]
  end

  def logout
    reset_session
    render
  end
end
