class AfterRegisterController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!

  steps :personal_details

  def show
    case step
    when :personal_details; end
    render_wizard
  end

  def update
    if @user == 'jobseeker'
      case step
      when :personal_details
        
    @user = current_user
    @user.update_attributes(params[:user])
    render_wizard @user
  end
end
