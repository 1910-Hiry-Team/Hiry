class AddFirstNameAndLastNameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :role, :integer
    add_column :users, :phone_number, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :skills, :string
    add_column :users, :hobbies, :string
    add_column :users, :city, :string
    add_column :users, :country, :string

    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
