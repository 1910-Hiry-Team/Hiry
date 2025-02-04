# app/policies/company/application_policy.rb
module Company
  class ApplicationPolicy < ApplicationPolicy
    def index?
      user_belongs_to_company?
    end

    def edit?
      user_belongs_to_company?
    end

    def update?
      user_belongs_to_company?
    end

    private

    def user_belongs_to_company?
      user.company == record.job.company
    end

    class Scope < Scope
      def resolve
        if user.company
          scope.joins(:job).where(jobs: { company_id: user.company.id })
        else
          scope.none
        end
      end
    end
  end
end
