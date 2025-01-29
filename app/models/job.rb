class Job < ApplicationRecord
  searchkick
  # Associations
  belongs_to :company
  has_many :applications
  has_many :users, through: :applications

  # Validations
  validates :job_title, presence: true
  validates :location, presence: true
  validates :missions, presence: true
  validates :contract, presence: true
  validates :salary, presence: true
  validates :language, presence: true
  validates :experience, presence: true
end
