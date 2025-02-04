class AddCountryToJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseeker_profiles, :country, :string
  end
end
