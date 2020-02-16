# frozen_string_literal: true

module FirstRegistration
  class ProspectiveEmployeePolicy < ApplicationPolicy
    def create?
      new?
    end

    def destroy?
      permitted? :destroy
    end

    def edit?
      permitted? :write
    end

    def index?
      permitted? :read
    end

    def new?
      permitted? :write
    end

    def update?
      edit?
    end

    private

    def permitted?(*privileges)
      user.privilege? :registration_management_for_employees, privileges
    end
  end
end
