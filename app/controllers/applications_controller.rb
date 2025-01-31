class ApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.company.jobs.all
  end

  def show
  end
end
