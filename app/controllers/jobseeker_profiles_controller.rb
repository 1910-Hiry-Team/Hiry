class JobseekerProfilesController < ApplicationController
  def article_params
    params.require(:jobseeker_profile).permit(:first_name, :last_name, :phone_number, :date_of_birth, :skills, :hobbies, :location, photo: [])
  end
end
