class Company < ApplicationRecord
  belongs_to :user
  has_many :jobs
  has_one_attached :photo

  # Validations
  validates :name, presence: true
  validates :employee_number, presence: true
  validates :industry, presence: true
  validates :location, presence: true
  validates :description, presence: true

  def self.industries
    [
      "Manufacturing",
      "Construction",
      "Transportation",
      "Chemical substance",
      "Mining",
      "Education",
      "Finance and insurance",
      "Food Manufacturing",
      "Health care",
      "Real estate",
      "Agriculture, forestry and fishing",
      "Arts, entertainment and recreation",
      "Entertainment",
      "Finance",
      "Food",
      "Music",
      "Oil and natural gas",
      "Retail",
      "Telecommunications",
      "Utilities",
      "Administrative and support services",
      "Agricultural sector",
      "Agriculture",
      "Apparel manufacturing"
    ]
  end

end
