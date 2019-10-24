# frozen_string_literal: true

class StudentDecorator < SimpleDelegator
  TOTAL_ECTS = 30

  def active_term
    @active_term ||= AcademicTerm.active.last
  end

  def calendar
    calendars.last
  end

  def registrable_for_online_course?
    calendar&.check_events('online_course_registrations')
  end

  def selected_ects
    @selected_ects ||= selected_courses.sum(&:ects).to_i
  end

  def selectable_ects
    @selectable_ects ||= TOTAL_ECTS - selected_ects
  end

  def selected_courses
    @selected_courses ||=
      course_enrollments.includes(available_course: [curriculum_course: %i[course curriculum_semester]])
                        .where(semester: semester)
  end

  def selected_catlog
    selected_courses.collect { |course_enrollment| [course_enrollment, can_drop?(course_enrollment)] }
  end

  def course_catalog
    course_catalog = []

    curriculum_semesters.each do |curriculum_semester|
      unless semester > curriculum_semester.sequence
        course_catalog << [curriculum_semester, course_catalog_for_semester(curriculum_semester)]
        return course_catalog unless !selectable_ects.negative? && enrolled_at?(curriculum_semester)
      end
    end
  end

  private

  def curriculum
    curriculums.active.last
  end

  def curriculum_semesters
    curriculum.semesters.where(term: active_term.term).order(:sequence)
  end

  def group_elective_ids_for(available_course)
    available_course.curriculum_course.curriculum_course_group.curriculum_courses
                    .joins(:available_courses).pluck('available_courses.id')
  end

  def enrolled_at_group?(available_course)
    (selected_courses.pluck(:available_course_id) & group_elective_ids_for(available_course)).any?
  end

  def max_sequence
    @max_sequence ||= selected_courses.pluck(:sequence).max
  end

  def can_enroll?(available_course)
    if available_course.type == 'elective' && enrolled_at_group?(available_course)
      return [false, translate('.already_enrolled_at_group')]
    end

    return [false, translate('.not_enough_ects')] if selectable_ects < available_course.ects

    true
  end

  def can_drop?(course_enrollment)
    max_sequence <= course_enrollment.available_course.curriculum_course.curriculum_semester.sequence
  end

  def course_catalog_for_semester(curriculum_semester)
    curriculum_semester.available_courses.includes(curriculum_course: %i[course curriculum_course_group])
                       .where(academic_term: active_term)
                       .where.not(id: selected_courses.pluck(:available_course_id))
                       .order('courses.name')
                       .collect { |available_course| [available_course, can_enroll?(available_course)].flatten }
  end

  def elective_ids_for(curriculum_semester)
    curriculum_semester.curriculum_course_groups
                       .joins(curriculum_courses: :available_courses)
                       .select('curriculum_course_groups.id, available_courses.id as available_course_id')
                       .group_by(&:id)
                       .collect { |_group_id, group| group.pluck('available_course_id') }
  end

  def compulsory_ids_for(curriculum_semester)
    curriculum_semester.curriculum_courses.compulsory
                       .includes(:available_courses)
                       .map(&:available_courses).flatten.pluck(:id)
  end

  def enrolled_at?(curriculum_semester)
    enrolled_course_ids = course_enrollments.pluck(:available_course_id)

    enrolled_at_electives = true
    elective_ids_for(curriculum_semester).each do |elective_ids|
      break unless enrolled_at_electives &&= (enrolled_course_ids & elective_ids).any?
    end

    enrolled_at_compulsories = (compulsory_ids_for(curriculum_semester) - enrolled_course_ids).empty?

    enrolled_at_electives && enrolled_at_compulsories
  end

  def translate(key)
    I18n.t("studentship.course_enrollments.new.#{key}")
  end
end
