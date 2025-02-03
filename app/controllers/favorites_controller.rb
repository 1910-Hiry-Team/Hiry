class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @favorite = Favorite.new
    @job = Job.find(params[:job_id])
    current_user.favorites.create(job: @job)

    respond_to do |format|
      format.html { redirect_back fallback_location: jobs_path }
      format.js   # Renders create.js.erb
    end
  end

  def index
    @favorites = current_user.favorites
    @jobs = @favorites.map(&:job)
  end

  def destroy
    @job = Job.find(params[:job_id])
    favorite = current_user.favorites.find_by(job_id: @job.id)
    favorite.destroy if favorite

    respond_to do |format|
      format.html { redirect_back fallback_location: jobs_path }
      format.js   # Renders destroy.js.erb
    end
  end
end
