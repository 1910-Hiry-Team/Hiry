class Job < ApplicationRecord
  geocoded_by :location
  after_validation :geocode, if: :location_changed?

  searchkick

  has_one_attached :photo

  # Associations
  belongs_to :company
  has_many :applications
  has_many :users, through: :applications
  has_many :favorites
  has_many :favorited_by_users, through: :favorites, source: :user

  # Validations
  validates :job_title, presence: true
  validates :location, presence: true
  validates :missions, presence: true
  validates :contract, presence: true
  validates :salary, presence: true
  validates :language, presence: true
  validates :experience, presence: true
end
