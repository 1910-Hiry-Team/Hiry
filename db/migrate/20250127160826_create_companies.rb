class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :email
      t.string :location
      t.string :description
      t.string :industry
      t.integer :employee_number
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
