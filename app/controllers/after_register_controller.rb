class AfterRegisterController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :set_user

  steps :personal_details, :birthdate, :location_details, :experience_details, :skills_hobbies_details,
        :name_of_company, :company_location, :company_details, :company_employee

  def show
    if step == 'wicked_finish'
      # return redirect_to user_after_register_path(user_id: @user.id, id: first_step_for(@user))
      return redirect_to finish_wizard_path(@user)
    end
    render_wizard
  end

  def update
    if @user.jobseeker?
      if @user.update(user_params)
        @user.after_register_current_step = steps.index(step) + 1 if steps.index(step) < steps.length - 1
        @user.save!
        render_wizard @user, form: 'jobseeker'
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        render_wizard @user, form: 'jobseeker'
      end
    elsif @user.company?
      if @user.update(user_params)
        render_wizard @user, form: 'company'
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        render_wizard @user, form: 'company'
      end
    end
  end

  private

  def first_step_for(user)
    user.jobseeker? ? :personal_details : :name_of_company
  end

  def set_user
    @user = User.find(params[:user_id])
    @user.build_jobseeker_profile if @user.jobseeker? && @user.jobseeker_profile.nil?
    @user.build_company if @user.company? && @user.company.nil?
  end

  def user_params
    if @user.jobseeker?
      case step
      when :personal_details
        params.require(:user).permit(
          jobseeker_profile_attributes: [:first_name, :last_name, :phone_number]
        )
      when :birthdate
        params.require(:user).permit(
          jobseeker_profile_attributes: [:date_of_birth]
        )
      when :location_details
        params.require(:user).permit(
          jobseeker_profile_attributes: [:city, :country]
        )
      when :experience_details
        params.require(:user).permit(
          jobseeker_profile_attributes: [experiences_attributes: [:company, :position, :start_date, :end_date, :description]]
        )
      when :skills_hobbies_details
        params.require(:user).permit(
          jobseeker_profile_attributes: [:skills, :hobbies]
        )
      end
    elsif @user.company?
      case step
      when :name_of_company
        params.require(:user).permit(
          company_attributes: [:name]
        )
      when :company_location
        params.require(:user).permit(
          company_attributes: [:location]
        )
      when :company_details
        params.require(:user).permit(
          company_attributes: [:employee_number, :industry, :description]
        )
      end
    end
  end

  def finish_wizard_path(user)
    if user.jobseeker?
      jobs_path
    elsif user.company?
      company_dashboard_path(user.company)
    else
      root_path
    end
  end
end
