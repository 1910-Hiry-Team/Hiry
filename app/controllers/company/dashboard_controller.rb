class Company::DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    @company = current_user.company
    authorize [:company, @company], :dashboard?
    @jobs = @company.jobs
  end

  private
end
