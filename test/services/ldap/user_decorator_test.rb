# frozen_string_literal: true

require 'test_helper'

module Ldap
  class UserDecoratorTest < ActiveSupport::TestCase
    setup do
      @user1 = Ldap::UserDecorator.new(users(:serhat))
      @user2 = Ldap::UserDecorator.new(users(:mine))
      @user3 = Ldap::UserDecorator.new(users(:john))
    end

    test 'user can respond to ldap_roles method' do
      assert_equal @user1.ldap_roles, %i[faculty student]
      assert_equal @user2.ldap_roles, %i[affiliate]
    end

    test 'user can respond to ldap_gender method' do
      assert_equal @user1.ldap_gender, '1'
      assert_equal @user2.ldap_gender, '9'
    end

    test 'user can respond to username method' do
      assert_equal @user1.username, users(:serhat).id_number
    end

    test 'user can respond to place_of_birth_for_ldap method' do
      assert_equal @user1.place_of_birth_for_ldap, 'Stockholm, İsveç'
    end

    test 'user can respond to identity method' do
      assert @user1.identity.is_a?(Identity)
    end

    test 'user can respond to faculty? method' do
      assert     @user1.faculty?
      assert_not @user2.faculty?
    end

    test 'user can respond to staff? method' do
      assert     @user3.staff?
      assert_not @user1.staff?
    end

    test 'user can respond to affiliate? method' do
      assert     @user2.affiliate?
      assert_not @user1.affiliate?
    end

    test 'user can respond to units_by method' do
      assert_includes     @user1.units_by(:faculty), units(:egitim_bilimleri_enstitusu)
      assert_not_includes @user1.units_by(:faculty), units(:uzem)
    end
  end
end
