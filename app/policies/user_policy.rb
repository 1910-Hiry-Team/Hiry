# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def show?
    # Users can only view their own profile
    user == record
  end
end
