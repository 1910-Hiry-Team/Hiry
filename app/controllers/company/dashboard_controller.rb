class Company::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_company_user!

  def index
    @company = current_user.company
    @jobs = @company.jobs
    @applications = @company.applications.includes(user: { jobseeker_profile: :first_name })
  end

  private

  def ensure_company_user!
    unless current_user.company?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
