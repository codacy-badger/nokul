# frozen_string_literal: true

require 'test_helper'

class HighSchoolTypeTest < ActiveSupport::TestCase
  include AssociationTestModule

  include ReferenceCallbacksTest
  include ReferenceValidationsTest

  setup do
    @object = high_schools_types(:aksam_lisesi)
  end

  # relations
  has_many :prospective_students
end
