# frozen_string_literal: true

class StudentDecorator < SimpleDelegator
  TOTAL_ECTS = 30

  def active_term
    @active_term ||= AcademicTerm.active.last
  end

  def registrable_for_online_course?
    calendar&.check_events('online_course_registrations')
  end

  def enrollment_status
    @enrollment_status ||= semester_enrollments.pluck(:status).include?('draft') ? :draft : :saved
  end

  def semester_enrollments
    @semester_enrollments ||=
      course_enrollments.includes(available_course: [curriculum_course: %i[course curriculum_semester]])
                        .where(semester: semester)
  end

  def fake_gpa
    @fake_gpa ||= student_number.to_s[0..1].to_f / 25
  end

  def plus_ects
    @plus_ects ||= case fake_gpa
                   when 1.8..2.49 then 6
                   when 2.5..2.99 then 10
                   when 3.0..3.49 then 12
                   when 3.5..4 then 15
                   else 0
                   end
  end

  def selected_ects
    @selected_ects ||= semester_enrollments.sum(&:ects).to_i
  end

  def selectable_ects
    @selectable_ects ||= TOTAL_ECTS + plus_ects - selected_ects
  end

  def selected_courses
    semester_enrollments.collect do |course_enrollment|
      [course_enrollment, can_drop?(course_enrollment.available_course)]
    end
  end

  def selectable_courses
    course_catalog = []

    curriculum_semesters.each do |curriculum_semester|
      unless semester > curriculum_semester.sequence
        course_catalog << [curriculum_semester, selectable_courses_for(curriculum_semester)]
        return course_catalog unless !selectable_ects.negative? && enrolled_at?(curriculum_semester)
      end
    end
  end

  private

  def calendar
    calendars.last
  end

  def curriculum
    curriculums.active.last
  end

  def curriculum_semesters
    curriculum.semesters.where(term: active_term.term).order(:sequence)
  end

  def group_elective_ids_of(available_course)
    available_course.curriculum_course.curriculum_course_group.curriculum_courses
                    .joins(:available_courses).pluck('available_courses.id')
  end

  def enrolled_at_group?(available_course)
    (semester_enrollments.pluck(:available_course_id) & group_elective_ids_of(available_course)).any?
  end

  def max_sequence
    @max_sequence ||= semester_enrollments.pluck(:sequence).max
  end

  def can_drop?(available_course)
    max_sequence <= available_course.curriculum_course.curriculum_semester.sequence
  end

  def can_add?(available_course)
    if available_course.type == 'elective' && enrolled_at_group?(available_course)
      return [false, translate('.already_enrolled_at_group')]
    end

    return [false, translate('.not_enough_ects')] if selectable_ects < available_course.ects

    true
  end

  def selectable_courses_for(curriculum_semester)
    curriculum_semester.available_courses.includes(curriculum_course: %i[course curriculum_course_group])
                       .where(academic_term: active_term)
                       .where.not(id: semester_enrollments.pluck(:available_course_id))
                       .order('courses.name')
                       .collect { |available_course| [available_course, can_add?(available_course)].flatten }
  end

  def enrolled_at?(curriculum_semester)
    curriculum_semester = CurriculumSemesterDecorator.new(curriculum_semester)
    enrolled_course_ids = semester_enrollments.pluck(:available_course_id)

    enrolled_at_compulsories = (curriculum_semester.compulsory_ids - enrolled_course_ids).empty?
    enrolled_at_electives = true

    curriculum_semester.elective_ids.each do |elective_ids|
      break unless enrolled_at_electives &&= (enrolled_course_ids & elective_ids).any?
    end

    enrolled_at_compulsories && enrolled_at_electives
  end

  def translate(key)
    I18n.t("studentship.course_enrollments.new.#{key}")
  end
end
