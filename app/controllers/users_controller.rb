class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update, :destroy]

  def edit
  end

  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        session[:weights] = nil
        format.html { redirect_to :weights, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params[:user]
    end
end
