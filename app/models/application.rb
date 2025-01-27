class Application < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :job

  # Validations
  validates :stage, presence: true
  validates :match, presence: true
end
