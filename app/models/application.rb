class Application < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :job
  belongs_to :applications

  # Validations
  validates :stage, inclusion: { in: ["Applied", "Interviewing", "Hired", "Rejected"] }
  validates :match, inclusion: { in: [true, false] }
end
