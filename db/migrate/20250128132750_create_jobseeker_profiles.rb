class CreateJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :jobseeker_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.date :date_of_birth
      t.string :skills
      t.string :hobbies
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
