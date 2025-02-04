# app/policies/favorite_policy.rb
class FavoritePolicy < ApplicationPolicy
  def create?
    # Only jobseekers can favorite jobs
    user.present? && !user.company.present?
  end

  def destroy?
    # Users can only remove their own favorites
    user == record.user
  end
end
