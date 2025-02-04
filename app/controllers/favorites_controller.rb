class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job

  def create
    @favorite = current_user.favorites.new(job: @job)
    authorize @favorite

    @favorite.save

    respond_to do |format|
      format.html { redirect_back fallback_location: jobs_path }
      format.js
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by!(job: @job)
    authorize @favorite

    @favorite.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: jobs_path }
      format.js
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end
end
