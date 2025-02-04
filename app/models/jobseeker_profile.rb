# app/models/jobseeker_profile.rb
class JobseekerProfile < ApplicationRecord
  belongs_to :user

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :date_of_birth, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :skills, presence: true

  after_initialize :set_defaults
  
  private

  def set_defaults
    self.phone_number ||= ""
    self.date_of_birth ||= nil
    self.city ||= ""
    self.country ||= ""
    self.skills ||= ""
  end
end
