# app/models/jobseeker_profile.rb
class JobseekerProfile < ApplicationRecord
  belongs_to :user

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  # validates :date_of_birth, presence: true
  # validates :city, presence: true
  # validates :country, presence: true
  # validates :skills, presence: true

  validate :validate_date_of_birth, on: :update
  validate :validate_location_details, on: :update
  validate :validate_skills_hobbies_details, on: :update

  after_initialize :set_defaults

  private

  def set_defaults
    self.phone_number ||= ""
    self.date_of_birth ||= nil
    self.city ||= ""
    self.country ||= ""
    self.skills ||= ""
  end

  def validate_date_of_birth
    if user&.after_register_current_step == :birthdate # Check if validation should be applied on :birthdate step
      errors.add(:date_of_birth, :blank) unless date_of_birth.present?
    end
  end

  def validate_location_details
    if user&.after_register_current_step == :location_details # Check if validation should be applied on :location_details step
      errors.add(:location, :blank) unless location.present?
      errors.add(:city, :blank) unless city.present?
      errors.add(:country, :blank) unless country.present?
    end
  end

  def validate_skills_hobbies_details
    if user&.after_register_current_step == :skills_hobbies_details # Check if validation on :skills_hobbies_details step
      errors.add(:skills, :blank) unless skills.present?
      errors.add(:hobbies, :blank) unless hobbies.present?
    end
  end
end
