# frozen_string_literal: true

require 'test_helper'

class EvaluationTypeTest < ActiveSupport::TestCase
  include AssociationTestModule

  setup do
    @evaluation_type = evaluation_types(:undergraduate_midterm)
  end

  # relations
  has_many :course_evaluation_types
  has_many :available_courses

  # validations: presence
  test 'presence validations for name of a evaluation type' do
    @evaluation_type.name = nil
    assert_not @evaluation_type.valid?
    assert_not_empty @evaluation_type.errors[:name]
  end

  # other validations
  test 'name can not be longer than 255 characters' do
    fake = @evaluation_type.dup
    fake.name = (0...256).map { ('a'..'z').to_a[rand(26)] }.join
    assert_not fake.valid?
    assert fake.errors.details[:name].map { |err| err[:error] }.include?(:too_long)
  end

  # callbacks
  test 'callbacks must titlecase the name of a evaluation type' do
    evaluation_type = EvaluationType.create!(name: 'test evaluation type')
    assert_equal evaluation_type.name, 'Test Evaluation Type'
  end
end
