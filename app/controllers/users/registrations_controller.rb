# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :configure_permitted_parameters

  def new
    build_resource({})
    if params[:role] == 'jobseeker'
      resource.build_jobseeker_profile
    elsif params[:role] == 'company'
      resource.build_company
    end
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      # Add this line for debugging
      puts "User validation errors: #{resource.errors.full_messages}"
      if resource.company
        puts "Company validation errors: #{resource.company.errors.full_messages}"
      end
      respond_with resource
    end
  end

  def after_sign_up_path_for(resource)
    if resource.company?
      company_jobs_path(resource.company)
    else
      search_jobs_path
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [
      :email, :password, :password_confirmation, :role,
      company_attributes: [:name, :location, :description, :industry, :employee_number],
      jobseeker_profile_attributes: [:first_name, :last_name, :phone_number, :date_of_birth, :skills, :hobbies, :location]
    ])
  end

  def company_params
    params.require(:user).require(:company_attributes).permit(
      :name, :email, :location, :description, :industry, :employee_number
    )
  end
end
