class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :role, photo: [])
  end
end
