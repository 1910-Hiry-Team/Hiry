class Company::JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :ensure_company_user!

  def index
    @jobs = @company.jobs
  end

  def new
    @job = @company.jobs.new
  end

  def show
    @job = @company.jobs.find(params[:id])
  end

  def create
    @job = @company.jobs.new(job_params)
    if @job.save
      redirect_to company_job_path(@company, @job), notice: "Job created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @job = @company.jobs.find(params[:id])
  end

  def update
    @job = @company.jobs.find(params[:id])
    if @job.update(job_params)
      redirect_to company_job_path(@company, @job), notice: "Job updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job = @company.jobs.find(params[:id])
    @job.destroy
    redirect_to company_jobs_path(@company), notice: "Job deleted successfully"
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def ensure_company_user!
    unless current_user.company == @company
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def job_params
    params.require(:job).permit(:job_title, :missions, :location, :contract, :language, :experience, :salary)
  end
end
