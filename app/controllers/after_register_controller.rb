class AfterRegisterController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :set_user

  steps :personal_details, :birthdate, :location_details, :experience_details, :skills_hobbies_details,
        :name_of_company, :company_location, :company_details, :company_employee

  def show
    # if @user.jobseeker?
    #   render_wizard @user, form: 'jobseeker'
    # elsif @user.company?
    #   render_wizard @user, form: 'company'
    # end
    if step == 'wicked_finish'
      return redirect_to user_after_register_path(user_id: @user.id, id: first_step_for(@user))
    end
    render_wizard
  end

  def update
    if @user.jobseeker?
      @user.update(user_params)
      render_wizard @user, form: 'jobseeker'
    elsif @user.company?
      @user.update(user_params)
      render_wizard @user, form: 'company'
    end
  end

  private

  def first_step_for(user)
    user.jobseeker? ? :personal_details : :name_of_company
  end
  
  def set_user
    @user = User.find(params[:user_id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone_number, :date_of_birth, :skills, :hobbies, :city, :country,
      company_attributes: [:name, :location, :description, :industry, :employee_number]
    )
  end

  def finish_wizard_path(user)
    if @user.jobseeker?
      jobs_path
    elsif @user.company?
      company_dashboard_path(@user.company)
    else
      root_path
    end
  end
end
