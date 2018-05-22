# frozen_string_literal: true

class Employee < ApplicationRecord
  # relations
  belongs_to :user
  belongs_to :title
  has_many :duties, dependent: :destroy
  has_many :units, through: :duties

  # validations
  validates :user, uniqueness: true

  # delegations
  delegate :identities, to: :user
end