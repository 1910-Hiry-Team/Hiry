class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  geocoded_by :job_location
  after_validation :geocode, if: :job_location_changed?
  def index
    @jobs = Job.all  # Add filtering logic here (search function)
  end

  def search
    # Show search form
    @jobs = Job.all
    @jobs = @jobs.search(params[:job_title]) if params[:job_title].present?
    @jobs = @jobs.near(params[:location], 50) if params[:location].present?
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
