class AfterRegisterController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!

  steps :jobseeker_signup, :personal_details :birthdate, :location_details, :experience_details, :skills_hobbies_details, :company_signup, :name_of_company, :company_location, :company_details, :company_employee

  def show
    if @user.jobseeker?
      render_wizard @user, form: 'jobseeker'
    elsif @user.company?
      render_wizard @user, form: 'company'
    end
  end

  def update
    if @user.jobseeker?
      @user.update(params[:user])
      render_wizard @user, form: 'jobseeker'
    elsif @user.company?
      @user.update(params[:user])
      render_wizard @user, form: 'company'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def finish_wizard_path
    if user.jobseeker?
      jobs_path
    elsif user.company?
      company_dashboard_path(user.company)
    end
  end
end
