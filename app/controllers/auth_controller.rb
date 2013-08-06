class AuthController < ApplicationController
  skip_before_filter :user_required

  def callback
    access_token = flash[:request_token].get_access_token(
      :oauth_verifier => params[:oauth_verifier])

    @user = User.find_or_create_authorized(access_token)
    session[:user_id] = @user.id

    redirect_to user_weights_path(@user)
  end

  def logout
    reset_session
    render
  end
end
