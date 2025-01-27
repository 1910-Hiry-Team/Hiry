class CreateStudies < ActiveRecord::Migration[7.1]
  def change
    create_table :studies do |t|
      t.string :school
      t.string :level
      t.string :diploma
      t.date :start_date
      t.date :end_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
