class Company < ApplicationRecord
  belongs_to :user
  has_many :jobs

  # Validations
  validates :name, presence: true
  validates :employee_number, :industry, :location, :description, presence: true, on: :complete
end
