class RemoveWizardFiledFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :wizard_step
  end
end
