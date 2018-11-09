# frozen_string_literal: true

scope module: :course_management do
  resources :courses
  resources :course_unit_groups
  resources :course_group_types, except: :show
  resources :curriculums

  resources :curriculum_semesters do
    resources :curriculum_semester_courses
  end
end
