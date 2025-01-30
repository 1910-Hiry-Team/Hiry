class ChangeSalaryTypeInJobs < ActiveRecord::Migration[7.1]
  def change
    remove_column :jobs, :salary
    add_column :jobs, :salary, :integer
  end
end
