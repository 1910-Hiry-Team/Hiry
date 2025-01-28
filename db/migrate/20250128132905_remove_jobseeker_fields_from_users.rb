class RemoveJobseekerFieldsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :phone_number
    remove_column :users, :date_of_birth
    remove_column :users, :skills
    remove_column :users, :hobbies
    remove_column :users, :city
    remove_column :users, :country
  end
end
