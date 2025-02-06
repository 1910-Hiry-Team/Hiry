class JobsController < ApplicationController

  before_action :set_job, only: [:show, :edit, :update, :destroy]
  def index
    @jobs = Job.all  # Add filtering logic here (search function)
  end

  def search
    # Show search form
    if params[:job_title].present?
      @jobs = Job.search(params[:job_title])
    else
      @jobs = Job.all
    end

    # Filter results by location if present
    if params[:location].present?
      # Get nearby job IDs using Geocoder
      nearby_jobs = Job.near(params[:location], 200).map(&:id)

      # If using Searchkick, ensure to intersect with geocoded results
      if params[:job_title].present?
        @jobs = @jobs.where(id: nearby_jobs)
      else
        @jobs = Job.where(id: nearby_jobs)
      end
    end
    render :index
  end

  def show
    @favorite = Favorite.new
    @application = Application.new
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

  def article_params
    params.require(:job).permit(:job_title, :location, :missions, :contract, :language, :experience, :salary, photo: [])
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end
end
