# frozen_string_literal: true

class CalendarType < ApplicationRecord
  # relations
  has_many :calendar_title_types, foreign_key: :type_id, inverse_of: :type, dependent: :destroy
  has_many :titles, through: :calendar_title_types
  has_many :academic_calendars, dependent: :destroy
  accepts_nested_attributes_for :calendar_title_types, reject_if: :all_blank, allow_destroy: true

  # validations
  validates :name, presence: true, uniqueness: true
end
