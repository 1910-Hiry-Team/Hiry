# app/policies/page_policy.rb
class PagePolicy < ApplicationPolicy
  def home?
    true  # Everyone can view the home page
  end

  def sign_up?
    true  # Everyone can view the sign up page
  end
end
