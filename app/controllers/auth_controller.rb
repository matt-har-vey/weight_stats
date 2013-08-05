class AuthController < ApplicationController
  def callback
    access_token = flash[:request_token].get_access_token(
      :oauth_verifier => params[:oauth_verifier])

    user = User.find_or_create_authorized(access_token)
    session[:user_id] = user.id

    redirect_to flash[:next_url]
  end

  def logout
    reset_session
    render
  end
end
