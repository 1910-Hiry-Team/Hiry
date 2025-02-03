# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :configure_permitted_parameters

  def new
    build_resource({})
    if params[:role].present?
      resource.role = params[:role] # Assigne le rôle à l'utilisateur
    end

    # Construction des profils (à garder)
    if params[:role] == 'jobseeker'
      resource.build_jobseeker_profile
    elsif params[:role] == 'company'
      resource.build_company
    end
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    puts "Params reçus : #{params.inspect}"

    # Assignation du rôle (UNE SEULE FOIS, avec sign_up_params)
    # Le rôle est déjà inclus dans sign_up_params grâce à configure_permitted_parameters

    puts "Rôle après assignation : #{resource.role}"

    if resource.save
      puts "User saved succesfully"
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        puts "User validation errors: #{resource.errors.full_messages}"
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      puts "User validation errors: #{resource.errors.full_messages}"
      if resource.company
        puts "Company validation errors: #{resource.company.errors.full_messages}"
      end
      respond_with resource
    end
  end

  def after_sign_up_path_for(resource)
    if resource.valid?
      if resource.jobseeker?
        redirect_to user_after_register_path(resource.id, step: 'personal_details')
      elsif resource.company?
        redirect_to user_after_register_path(resource.company.id, step: 'name_of_company')
      end
    else
      super
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role,
                                 jobseeker_profile_attributes: [:first_name, :last_name, :phone_number, :date_of_birth, :skills, :hobbies, :city, :country],
                                 company_attributes: [:name, :location, :description, :industry, :employee_number])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email, :password, :password_confirmation, :role,
      jobseeker_profile_attributes: [:first_name, :last_name, :phone_number, :date_of_birth, :skills, :hobbies, :city, :country],
      company_attributes: [:name, :location, :description, :industry, :employee_number]
    ])
    # Pas besoin de répéter les clés ici, elles sont déjà dans sign_up_params
  end
end

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [
  #     :email, :password, :password_confirmation, :role,
  #     company_attributes: [:name, :location, :description, :industry, :employee_number]  # removed :email from here
  #   ])
  # end

  # def jobseeker_profile_params
  #   params.require(:user).require(:jobseeker_profile_attributes).permit(
  #     :first_name, :last_name, :phone_number, :date_of_birth, :skills, :hobbies, :city, :country
  #   )
  # end

  # def company_params
  #   params.require(:user).require(:company_attributes).permit(
  #     :name, :email, :location, :description, :industry, :employee_number
  #   )
  # end
