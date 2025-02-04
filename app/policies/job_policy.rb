# app/policies/job_policy.rb
class JobPolicy < ApplicationPolicy
  def index?
    true  # Everyone can see jobs
  end

  def show?
    true  # Everyone can view job details
  end

  def search?
    true  # Everyone can search jobs
  end

  class Scope < Scope
    def resolve
      # Show all active jobs
      # You might want to add conditions like:
      # - Only show active/published jobs
      # - Don't show expired jobs
      scope.all
    end
  end
end
