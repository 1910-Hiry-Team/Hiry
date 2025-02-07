class Job < ApplicationRecord
  include AlgoliaSearch

  geocoded_by :location
  after_validation :geocode, if: :location_changed?

  # Algolia configuration
  algoliasearch do
    attribute :job_title
    searchableAttributes ['job_title']
    customRanking ['desc(updated_at)']
  end

  # Active Storage
  has_one_attached :photo

  # Associations
  belongs_to :company
  has_many :applications, dependent: :destroy
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
