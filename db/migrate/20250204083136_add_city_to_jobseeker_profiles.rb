class AddCityToJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseeker_profiles, :city, :string
  end
end
