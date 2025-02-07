class Application < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :job

  has_one :company, through: :jobs


  # Validations
  validates :stage, inclusion: { in: ["Applied", "Interviewing", "Hired", "Rejected"] }
  validates :match, inclusion: { in: [true, false] }
end
