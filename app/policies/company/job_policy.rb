# app/policies/company/job_policy.rb
module Company
  class JobPolicy < ApplicationPolicy
    def index?
      user_belongs_to_company?
    end

    def show?
      user_belongs_to_company?
    end

    def create?
      user_belongs_to_company?
    end

    def new?
      create?
    end

    def update?
      user_belongs_to_company?
    end

    def edit?
      update?
    end

    def destroy?
      user_belongs_to_company?
    end

    private

    def user_belongs_to_company?
      return false unless user.present?
      user.company == record.company
    end

    # Optional: If you want to authorize collections (like in index action)
    class Scope < Scope
      def resolve
        if user.company
          scope.where(company: user.company)
        else
          scope.none
        end
      end
    end
  end
end
