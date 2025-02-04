class JobsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  before_action :set_job, only: [:show]

  def index
    @jobs = policy_scope(Job)
  end

  def search
    @jobs = policy_scope(Job)
    @jobs = @jobs.search(params[:job_title]) if params[:job_title].present?
    @jobs = @jobs.near(params[:location], 200) if params[:location].present?
    render :index
  end

  def show
    authorize @job
    @favorite = Favorite.new
    @application = Application.new
  end

  # Remove unused actions since they're handled in Company::JobsController
  private

  def set_job
    @job = Job.find(params[:id])
  end
end
