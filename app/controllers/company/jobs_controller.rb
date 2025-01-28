class Company::JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_company_user!

  def index
    @jobs = current_user.company.jobs
  end

  private

  def ensure_company_user!
    unless current_user.company?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
