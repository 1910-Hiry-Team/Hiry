# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :configure_permitted_parameters

  def new
    session[:registration_params] ||= {}
    @user = User.new(session[:registration_params])
    @role = params[:role]
    @step = params[:step].to_i

    @step = 1 if @step < 1

    if @role == 'jobseeker' && @step > 1
      @total_steps = jobseeker_total_steps
      @user.build_jobseeker_profile unless @user.jobseeker_profile
    elsif @role == 'company' && @step > 1
      @total_steps = company_total_steps
      @user.build_company unless @user.company
    end
    
    render :new
  end

  def create
    session[:registration_params].deep_merge!(sign_up_params)
    @user = User.new(session[:registration_params])
    @role = session[:registration_params]["role"]
    @step = params[:step].to_i

    if @role == 'jobseeker'
      @total_steps = jobseeker_total_steps
    elsif @role == 'company'
      @total_steps = company_total_steps
    else
      @total_steps = 1
    end

    if @step == @total_steps
      if @user.valid?
        if @user.save
          session[:registration_params] = nil
          set_flash_message! :notice, :signed_up
          sign_up(ressource_name, @user)
          respond_with @user, location: after_sign_up_path_for(@user)
        else
          clean_up_passwords @user
          set_minimum_password_length
          @step = @total_steps
          render :new
        end
      else
        clean_up_passwords @user
        set_minimum_password_length
        @step = @total_steps
        render :new
      end
    else
      @step += 1
      render :new
    end
  end

  def after_sign_up_path_for(resource)
    if resource.company?
      company_jobs_path(resource.company)
    else
      search_jobs_path
    end
  end



  # def new
  #   build_resource({})
  #   if params[:role] == 'jobseeker'
  #     resource.build_jobseeker_profile
  #   elsif params[:role] == 'company'
  #     resource.build_company
  #   end
  #   respond_with resource
  # end

  # def create
  #   build_resource(sign_up_params)

  #   if resource.save
  #     if resource.active_for_authentication?
  #       set_flash_message! :notice, :signed_up
  #       sign_up(resource_name, resource)
  #       respond_with resource, location: after_sign_up_path_for(resource)
  #     else
  #       set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
  #       expire_data_after_sign_in!
  #       respond_with resource, location: after_inactive_sign_up_path_for(resource)
  #     end
  #   else
  #     clean_up_passwords resource
  #     set_minimum_password_length
  #     # Add this line for debugging
  #     puts "User validation errors: #{resource.errors.full_messages}"
  #     if resource.company
  #       puts "Company validation errors: #{resource.company.errors.full_messages}"
  #     end
  #     respond_with resource
  #   end
  # end

  # def after_sign_up_path_for(resource)
  #   if resource.company?
  #     company_jobs_path(resource.company)
  #   else
  #     search_jobs_path
  #   end
  # end

  private

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

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role] || {})
  end

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up).merge(step_params[@step] || {})
  end

  def jobseeker_total_steps
    5
  end

  def company_total_steps
    4
  end

  def step_params
    {
      1 => [:email, :password, :password_confirmation, :role], # Step 1: Devise base user attributes
      2 => { jobseeker_profile_attributes: [:first_name, :last_name] }, # Step 2: Jobseeker Profile - Personal Info
      3 => { jobseeker_profile_attributes: [:phone_number, :date_of_birth, :city, :country] }, # Step 3: Jobseeker Profile - Contact & Location
      4 => { jobseeker_profile_attributes: [:skills, :hobbies] }, # Step 4: Jobseeker Profile - Skills & Hobbies
      5 => {}, # Step 5: Review - No params to permit

      2 => { company_attributes: [:name, :location, :industry, :employee_number] }, # Step 2: Company Info Part 1
      3 => { company_attributes: [:description] }, # Step 3: Company Info Part 2
      4 => {} # Step 4: Review - No params to permit for company
    }
  end
end
