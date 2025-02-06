class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
    if current_user.company
      @company = current_user.company
    else
      @profile = current_user.jobseeker_profile
    end
  end
end
