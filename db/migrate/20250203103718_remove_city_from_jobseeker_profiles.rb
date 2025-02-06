class RemoveCityFromJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    remove_column :jobseeker_profiles, :city, :string
    remove_column :jobseeker_profiles, :country, :string
  end
end
