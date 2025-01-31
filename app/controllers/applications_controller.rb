class ApplicationsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def new
    @application = Application.new
  end

  def create
    @job = Job.find(params[:job_id])
    @application = current_user.applications.new(application_params)
    if @application.save
      redirect_to @job, notice: 'Application was successfully created.'
    else
      render :new
    end
  end

  private

  def application_params
    params.require(:application).permit(:stage, :match, :job_id)
  end
end
