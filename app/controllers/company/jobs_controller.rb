class Company::JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  # Remove ensure_company_user! as Pundit will handle this now

  def index
    @jobs = policy_scope([:company, @company.jobs])
  end

  def new
    @job = @company.jobs.new
    authorize [:company, @job]
  end

  def show
    @job = @company.jobs.find(params[:id])
    authorize [:company, @job]
  end

  def create
    @job = @company.jobs.new(job_params)
    authorize [:company, @job]
    if @job.save
      redirect_to company_job_path(@company, @job), notice: "Job created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @job = @company.jobs.find(params[:id])
    authorize [:company, @job]
  end

  def update
    @job = @company.jobs.find(params[:id])
    authorize [:company, @job]
    if @job.update(job_params)
      redirect_to company_job_path(@company, @job), notice: "Job updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job = @company.jobs.find(params[:id])
    authorize [:company, @job]
    @job.destroy
    redirect_to company_jobs_path(@company), notice: "Job deleted successfully"
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def job_params
    params.require(:job).permit(:job_title, :missions, :location, :contract, :language, :experience, :salary)
  end
end
