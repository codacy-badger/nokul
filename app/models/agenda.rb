# frozen_string_literal: true

class Agenda < ApplicationRecord
  # search
  include PgSearch
  include DynamicSearch

  pg_search_scope(
    :search,
    against: %i[description],
    using: { tsearch: { prefix: true } }
  )

  # dynamic_search
  search_keys :status, :agenda_type_id

  # relations
  has_one_attached :agenda_file
  belongs_to :unit
  belongs_to :agenda_type

  # validations
  validates :description, presence: true
  validates :status, presence: true

  # enums
  enum status: { recent: 0, decided: 1, delayed: 2 }
end