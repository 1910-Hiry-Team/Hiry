# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    # Only the applicant can see their application
    user == record.user
  end

  def create?
    # Any jobseeker can create an application
    # You might want to add additional checks like:
    # - user isn't the job's company
    # - user hasn't already applied
    user.present? && !user.company.present?
  end

  def new?
    create?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
