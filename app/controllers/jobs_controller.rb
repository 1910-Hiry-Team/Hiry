class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  def index
    @jobs = Job.all  # Add filtering logic here (search function)
  end

  def search
    # Show search form
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

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params

  end
end
