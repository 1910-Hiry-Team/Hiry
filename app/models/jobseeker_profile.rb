# app/models/jobseeker_profile.rb
class JobseekerProfile < ApplicationRecord
  belongs_to :user

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :date_of_birth, presence: true
  validates :location, presence: true
  validates :skills, presence: true
end
