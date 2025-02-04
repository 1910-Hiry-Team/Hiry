class ApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [:new, :create]

  def index
    @applications = policy_scope(Application)
  end

  def show
    @application = Application.find(params[:id])
    authorize @application
  end

  def new
    @application = @job.applications.new
    authorize @application
  end

  def create
    @application = current_user.applications.new(application_params)
    @application.job = @job
    authorize @application

    if @application.save
      redirect_to @job, notice: 'Application was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def application_params
    params.require(:application).permit(:stage, :match)
  end
end
