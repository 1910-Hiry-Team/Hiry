class RemoveEmailFromCompanies < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :email, :string
  end
end
