# frozen_string_literal: true

module CourseManagement
  class EnrolledCoursesController < ApplicationController
    before_action :set_student
    before_action :set_curriculum
    before_action :set_term

    def index
      @students = current_user.students.includes(:unit)
      @semesters = @curriculum.semesters.where(term: @term.term).order(:sequence)
    end

    private

    def redirect_with(message)
      redirect_to(:root, alert: t(".#{message}"))
    end

    def set_student
      student =
        if (student_id = params[:student_id].presence)
          current_user.students.find(student_id)
        else
          current_user.students.first
        end

      @student = StudentDecorator.new(student)
    end

    def set_curriculum
      @curriculum = @student.unit.curriculums.active.last
      redirect_with('active_curriculum_not_found') unless @curriculum
    end

    def set_term
      @term = AcademicTerm.active.last
      redirect_with('active_term_not_found') unless @term
    end
  end
end
