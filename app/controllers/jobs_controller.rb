class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  def index
    @jobs = Job.all  # Add filtering logic here (search function)
  end

  def search
    # Show search form
    @jobs = Job.all
    @jobs = Job.search(params[:job_title]) if params[:job_title].present?
    @jobs = @jobs.near(params[:location], 200) if params[:location].present?
    render :index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params

  end
end
