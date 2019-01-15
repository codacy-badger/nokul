# frozen_string_literal: true

module Admin
  class StudentDisabilityTypesController < ApplicationController
    include ReferenceResource

    private

    def secure_params
      params.require(:student_disability_type).permit(:name, :code)
    end
  end
end