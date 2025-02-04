class Company < ApplicationRecord
  belongs_to :user
  has_many :jobs
  has_one_attached :logo

  # Validations
  validates :name, presence: true
  validates :employee_number, presence: true
  validates :industry, presence: true
  validates :location, presence: true
  validates :description, presence: true
end
