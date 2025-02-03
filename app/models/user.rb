class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { jobseeker: 'jobseeker', company: 'company' }

  before_validation :convert_role_to_integer

  # Associations based on profile
  has_one :jobseeker_profile, dependent: :destroy
  has_one :company, dependent: :destroy

  # Associations
  has_many :favorites
  has_many :favorite_jobs, through: :favorites, source: :job
  has_many :applications, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :studies, dependent: :destroy
  has_many :jobs, through: :applications

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  accepts_nested_attributes_for :jobseeker_profile
  accepts_nested_attributes_for :company

  private

  def convert_role_to_integer
    self.role = User.roles[role] if role.is_a?(String)
  end

end
