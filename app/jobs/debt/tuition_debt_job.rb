# frozen_string_literal: true

module Debt
  class TuitionDebtJob < ApplicationJob
    queue_as :high

    def perform(unit_ids, term_id, due_date)
      units = Unit.where(id: unit_ids.reject(&:empty?)).select { |u| u.students.active.exists? }

      Debt::Tuition::Dispatch.perform(units.flatten, term_id, due_date)
    end
  end
end
