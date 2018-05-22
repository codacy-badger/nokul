# frozen_string_literal: true

require 'test_helper'

class IdentityTest < ActiveSupport::TestCase
  # relations
  %i[
    user
    student
  ].each do |property|
    test "an identity can communicate with #{property}" do
      assert identities(:serhat).send(property)
    end
  end

  # validations: presence
  %i[
    name
    first_name
    last_name
    gender
    place_of_birth
    date_of_birth
  ].each do |property|
    test "presence validations for #{property} of a user" do
      identities(:serhat).send("#{property}=", nil)
      assert_not identities(:serhat).valid?
      assert_not_empty identities(:serhat).errors[property]
    end
  end

  # validations: uniqueness
  test 'users can not save duplicate identities' do
    fake = identities(:serhat).dup
    assert_not fake.valid?
    assert_not_empty fake.errors[:name]
  end

  # enumerations
  %i[
    formal?
    male?
    married?
  ].each do |property|
    test "identities can respond to #{property} enum" do
      assert identities(:serhat).send(property)
    end
  end
end