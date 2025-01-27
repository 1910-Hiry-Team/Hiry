class Study < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :diploma, presence: true
  validates :school, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :level, presence: true
end
