class AddLocationToJobseekerprofiles < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseeker_profiles, :location, :string
  end
end
