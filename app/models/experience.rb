class Experience < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :company, presence: true
  validates :job_title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
end
