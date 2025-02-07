class DashboardController < ApplicationController
  def index
    @company = current_user.company
    @applications = Application.where(job_id: @company.jobs.ids)
  end
end
