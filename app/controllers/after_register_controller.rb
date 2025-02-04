class AfterRegisterController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :set_user

  steps :personal_details, :birthdate, :location_details, :experience_details, :skills_hobbies_details,
        :name_of_company, :company_location, :company_details, :company_employee

  def show
    if step == 'wicked_finish'
      return redirect_to finish_wizard_path(@user)
    end
    render_wizard
  end

  def update
    puts "Params: #{params.inspect}"
    if @user.jobseeker?
      if @user.update(jobseeker_params)
        @user.after_register_current_step = steps.index(step) + 1 if steps.index(step) < steps.length - 1
        @user.save!

        puts "@user.after_register_current_step before render_wizard: #{@user.after_register_current_step.inspect}" # DEBUG
        puts "About to render_wizard for jobseeker, step: #{step}" # DEBUG
        render_wizard @user, form: 'jobseeker'
        puts "render_wizard completed for jobseeker" # DEBUG
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        render_wizard @user, form: 'jobseeker'
      end
    elsif @user.company?
      if @user.update(company_params)
        @user.after_register_current_step = steps.index(step) + 1 if steps.index(step) < steps.length - 1
        @user.save!
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

  def jobseeker_params
    case step
    when :personal_details
      params.require(:user).permit(jobseeker_profile_attributes: [:first_name, :last_name, :phone_number])
    when :birthdate
      params.require(:user).permit(jobseeker_profile_attributes: [:date_of_birth])
    when :location_details
      params.require(:user).permit(jobseeker_profile_attributes: [:city, :country])
    when :experience_details
      params.require(:user).permit(jobseeker_profile_attributes: [experiences_attributes: [:company, :position, :start_date, :end_date, :description]])
    when :skills_hobbies_details
      params.require(:user).permit(jobseeker_profile_attributes: [:skills, :hobbies])
    else
      {}
    end
  end

  def company_params
    case step
    when :name_of_company
      params.require(:user).permit(company_attributes: [:name])
    when :company_location
      params.require(:user).permit(company_attributes: [:location])
    when :company_details
      params.require(:user).permit(company_attributes: [:employee_number, :industry, :description])
    when :company_employee # Ajout de l'étape company_employee (manquait dans ton code initial)
      params.require(:user).permit(company_attributes: [:employee_range]) # Exemple, ajuste selon tes attributs
    else
      {} # Retourne un hash vide par défaut pour les étapes non gérées ici
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
