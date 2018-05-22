# frozen_string_literal: true

require 'test_helper'

class DutyTest < ActiveSupport::TestCase
  # relations
  %i[
    employee
    unit
  ].each do |property|
    test "a duty can communicate with #{property}" do
      assert duties(:baum).send(property)
    end
  end

  # validations: presence
  %i[
    temporary
    start_date
    employee
    unit
  ].each do |property|
    test "presence validations for #{property} of a duty" do
      duties(:baum).send("#{property}=", nil)
      assert_not duties(:baum).valid?
      assert_not_empty duties(:baum).errors[property]
    end
  end

  # validations: uniqueness
  test 'duplication validations for unit' do
    fake = duties(:baum).dup
    assert_not fake.valid?
    assert_not_empty fake.errors[:unit_id]
  end
end