class Company < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :jobs

  # Validations
  validates :name, presence: true
  validates :employee_number, presence: true
  validates :industry, presence: true
  validates :location, presence: true
  validates :description, presence: true
end
