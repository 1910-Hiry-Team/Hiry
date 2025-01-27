class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :applications
  has_many :experiences
  has_many :studies
  has_many :companies

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :first_name, presence: true, if: :jobseeker?
  validates :last_name, presence: true, if: :jobseeker?
  validates :phone_number, presence: true, if: :jobseeker?, uniqueness: true
  validates :date_of_birth, presence: true, if: :jobseeker?
  validates :skills, presence: true, if: :jobseeker?
  validates :city, presence: true, if: :jobseeker?
  validates :country, presence: true, if: :jobseeker?

  enum role: { jobseeker: 0, recruiter: 1 }
end
