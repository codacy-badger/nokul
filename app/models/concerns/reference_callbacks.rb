# frozen_string_literal: true

module ReferenceCallbacks
  extend ActiveSupport::Concern

  included do
    after_commit do
      self.name = name.capitalize_all
    end
  end
end