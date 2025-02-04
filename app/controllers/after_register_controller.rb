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
    params_to_update = @user.jobseeker? ? jobseeker_params : company_params

    @user.assign_attributes(params_to_update)
    if @user.save(context: step)
      update_current_step_and_render_wizard(@user.jobseeker? ? 'jobseeker' : 'company')
    else
      render_error_and_wizard(@user.jobseeker? ? 'jobseeker' : 'company')
    end
    # if @user.jobseeker?
    #   puts "@user.class: #{@user.class}"
    #   case step # Utilisation de case step pour les étapes jobseeker
    #   when :personal_details
    #     if @user.update(jobseeker_params, context: step) # Utilise jobseeker_params pour jobseeker
    #       update_current_step_and_render_wizard('jobseeker') # Méthode factorisée pour la logique commune
    #     else
    #       render_error_and_wizard('jobseeker') # Méthode factorisée pour la gestion des erreurs
    #     end
    #   when :birthdate
    #     if @user.update(jobseeker_params, context: step) # Utilise jobseeker_params pour jobseeker
    #       update_current_step_and_render_wizard('jobseeker') # Méthode factorisée pour la logique commune
    #     else
    #       render_error_and_wizard('jobseeker') # Méthode factorisée pour la gestion des erreurs
    #     end
    #   when :location_details # Ajoute les autres étapes jobseeker ici...
    #     if @user.update(jobseeker_params, context: step)
    #       update_current_step_and_render_wizard('jobseeker')
    #     else
    #       render_error_and_wizard('jobseeker')
    #     end
    #   when :experience_details
    #     if @user.update(jobseeker_params, context: step)
    #       update_current_step_and_render_wizard('jobseeker')
    #     else
    #       render_error_and_wizard('jobseeker')
    #     end
    #   when :skills_hobbies_details
    #     if @user.update(jobseeker_params, context: step)
    #       update_current_step_and_render_wizard('jobseeker')
    #     else
    #       render_error_and_wizard('jobseeker')
    #     end
    #   end

    # elsif @user.company?
    #   case step # Utilisation de case step pour les étapes company
    #   when :name_of_company
    #     if @user.update(company_params, context: step) # Utilise company_params pour company
    #       update_current_step_and_render_wizard('company') # Méthode factorisée pour la logique commune
    #     else
    #       render_error_and_wizard('company') # Méthode factorisée pour la gestion des erreurs
    #     end
    #   when :company_location
    #     if @user.update(company_params, context: step)
    #       update_current_step_and_render_wizard('company')
    #     else
    #       render_error_and_wizard('company')
    #     end
    #   when :company_details # Ajoute les autres étapes company ici...
    #     if @user.update(company_params, context: step)
    #       update_current_step_and_render_wizard('company')
    #     else
    #       render_error_and_wizard('company')
    #     end
    #   when :company_employee
    #     if @user.update(company_params, context: step)
    #       update_current_step_and_render_wizard('company')
    #     else
    #       render_error_and_wizard('company')
    #     end
    #   end
    # end
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
      params.require(:user).permit(jobseeker_profile_attributes: [:location, :city, :country])
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

  def update_current_step_and_render_wizard(form_type)
    @user.after_register_current_step = steps.index(step) + 1 if steps.index(step) < steps.length - 1
    @user.save! # Sauvegarde explicite après mise à jour de after_register_current_step
    render_wizard @user, form: form_type
  end

  def render_error_and_wizard(form_type)
    flash.now[:alert] = @user.errors.full_messages.join(", ")
    render_wizard @user, form: form_type
  end
end
