class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { jobseeker: 'jobseeker', company: 'company' }

  # Associations based on profile
  has_one :jobseeker_profile, inverse_of: :user
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
  validates :role, presence: true, inclusion: { in: ['jobseeker', 'company'] }

  accepts_nested_attributes_for :jobseeker_profile, update_only: true
  accepts_nested_attributes_for :company

  def after_register_current_step
    @after_register_current_step || 1
  end

  def after_register_current_step=(step)
    @after_register_current_step = step
  end
end
