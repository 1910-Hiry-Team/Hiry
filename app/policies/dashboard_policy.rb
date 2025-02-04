# app/policies/dashboard_policy.rb
class DashboardPolicy < ApplicationPolicy
  def index?
    # Only company users can access their dashboard
    user.present? && user.company == record
  end
end
