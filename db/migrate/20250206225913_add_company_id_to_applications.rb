class AddCompanyIdToApplications < ActiveRecord::Migration[7.1]
  def change
    add_reference :applications, :company, foreign_key: true
  end
end
