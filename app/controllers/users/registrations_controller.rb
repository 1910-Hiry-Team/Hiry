# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  include Wicked::Wizard
  skip_before_action :authenticate_user!, only: [:new, :create, :show, :update] # Add show and update to skip auth
  before_action :configure_permitted_parameters

  # Define steps dynamically based on role
  def steps
    case params[:role]
    when 'jobseeker'
      [:role_step, :personal_details, :contact_details, :experience_info, :skills_hobbies, :confirmation] # Updated step order
    when 'company'
      [:role_step, :company_info_part1, :company_info_part2, :confirmation]
    else
      [:role_step]
    end
  end
  attr_accessor :total_steps # You won't need this with wicked

  # This line is crucial to tell wicked about your steps
  steps *steps # Call the steps method to define them

  def show
    @role = params[:role] # Ensure role is available in show
    case step
    when :role_step
      @user = User.new # For role selection, if needed as a step
    when :personal_details # Jobseeker Step 2
      @user = User.find(params[:user_id]) || User.new # Find existing user or new
      @user.build_jobseeker_profile unless @user.jobseeker_profile
    when :contact_details # Jobseeker Step 3
      @user = User.find(params[:user_id]) # Find existing user
    when :skills_hobbies # Jobseeker Step 4
      @user = User.find(params[:user_id]) # Find existing user
    when :company_info_part1 # Company Step 2
      @user = User.find(params[:user_id]) || User.new # Find existing user or new
      @user.build_company unless @user.company
    when :company_info_part2 # Company Step 3
      @user = User.find(params[:user_id]) # Find existing user
    when :confirmation # Last step for both
      @user = User.find(params[:user_id]) # Find existing user
    end
    render_wizard
  end

  def new # Corrected new action
    @role = params[:role] # Keep role parameter
    @user = User.new # Initialize a new user
    redirect_to wizard_path(steps.first, role: @role) # Redirect to the first step
  end

  def update
    @role = params[:role] # Ensure role is available in update
    @user = User.find(params[:id]) || User.new # Find existing user or new

    case step
    when :role_step # If role selection is a step
      @user.role = params[:user][:role] if params[:user] && params[:user][:role] # Set role
    when :personal_details
      @user.attributes = user_params.merge(step: step) # Merge step for tracking if needed
    when :contact_details
      @user.attributes = user_params.merge(step: step)
    when :skills_hobbies
      @user.attributes = user_params.merge(step: step)
    when :company_info_part1
      @user.attributes = user_params.merge(step: step)
    when :company_info_part2
      @user.attributes = user_params.merge(step: step)
    end

    if params[:commit] == "Previous" # Handle previous button
      render_wizard @user, previous_step: true
    else
      # For "Next Step" or "Submit"
      if step == steps.last # Last step (confirmation)
        if @user.save # Final save on last step
          session[:registration_params] = nil # No longer need session
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, @user)
          respond_with @user, location: after_sign_up_path_for(@user)
        else
          clean_up_passwords @user
          set_minimum_password_length
          render_wizard @user # Re-render confirmation step with errors
        end
      else
        render_wizard @user # Render next step, validations handled by model
      end
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role] || {})
  end

  def sign_up_params
    permitted_params = params.require(:user).permit(
      :email, :password, :password_confirmation, :role, :step,
      jobseeker_profile_attributes: [:first_name, :last_name, :phone_number, :date_of_birth, :city, :country, :skills, :hobbies],
      company_attributes: [:name, :location, :industry, :employee_number, :description],
      experiences_attributes: [:company, :job_title, :start_date, :end_date, :missions] # Permit experience attributes
    )
    permitted_params
  end
end
