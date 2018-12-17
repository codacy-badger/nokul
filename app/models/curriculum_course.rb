# frozen_string_literal: true

class CurriculumCourse < ApplicationRecord
  self.inheritance_column = :_type_disabled

  # enums
  enum type: { compulsory: 0, elective: 1 }

  # relations
  belongs_to :course
  belongs_to :curriculum_semester
  belongs_to :curriculum_course_group, optional: true

  # validations
  validates :ects, numericality: { greater_than: 0 }
  validates :type, inclusion: { in: types.keys }

  # delegates
  delegate :code, :credit, :course_type, :name, to: :course

  # callbacks
  before_validation do
    self.type = curriculum_course_group_id.nil? ? :compulsory : :elective
  end
end