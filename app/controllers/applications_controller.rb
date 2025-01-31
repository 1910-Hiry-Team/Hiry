class ApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.company.jobs.all
  end

  def show
    @application = Application.find(params[:id])
    @company = current_user.company
  end

  def edit
  end
end
