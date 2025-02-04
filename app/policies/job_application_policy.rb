# app/policies/job_application_policy.rb
class JobApplicationPolicy < ApplicationPolicy
  def index?
    user.company.present?
  end

  def show?
    # Only the applicant can see their application
    # Or the company the application was sent to
    user == record.user || (user.company? && user.company == record.job.company)
  end

  def create?
    # Any jobseeker can create an application
    # As long as they haven't already applied
    super && !record.job.applications.exists?(user: user)
  end

  class Scope < Scope
    def resolve
      if user.company?
        # Companies see applications for their jobs
        scope.joins(:job).where(jobs: { company_id: user.company.id })
      else
        # Regular users see their own applications
        scope.where(user: user)
      end
    end
  end
end
