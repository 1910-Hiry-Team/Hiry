class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.string :job_title
      t.string :location
      t.string :missions
      t.string :contract
      t.string :language
      t.string :experience
      t.int4range :salary
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
