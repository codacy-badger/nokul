# frozen_string_literal: true

module Nokul
  module Support
    module Codifications
      class PrefixedCoder
        Error = Class.new ::StandardError

        MINIMUM_SEQUENCE_LENGTH = 3
        DEFAULT_NUMBER_LENGTH   = 8

        class_attribute :length, default: DEFAULT_NUMBER_LENGTH

        def initialize(starting_sequence, prefix: '', **coder_options)
          @starting_sequence = starting_sequence
          @prefix            = [*prefix].join
          @coder             = build_coder(**coder_options)
        end

        def run
          prefix + coder.run
        end

        def initial_sequence
          '0' * (effective_sequence_length - 1) + '1'
        end

        def next_sequence
          coder.peek
        end

        protected

        attr_reader :starting_sequence, :prefix, :coder

        def build_coder(**coder_options)
          sanitize_setup(**coder_options)
          Coder.new starting_sequence.presence || initial_sequence, **coder_options
        end

        def effective_sequence_length
          length - prefix.length
        end

        def sanitize_setup(**)
          numerator_length_must_be_sane
          effective_sequence_length_must_be_sane
          starting_sequence_must_be_sane
        end

        def numerator_length_must_be_sane
          raise Error, 'Coder length undefined' unless length
          raise Error, "Coder length is too short: #{length}" if length < MINIMUM_SEQUENCE_LENGTH
        end

        def effective_sequence_length_must_be_sane
          return if effective_sequence_length >= MINIMUM_SEQUENCE_LENGTH

          raise Error, 'Effective sequence length is too short'
        end

        def starting_sequence_must_be_sane
          return if starting_sequence.blank? || starting_sequence.length == effective_sequence_length

          raise Error, "Incorrect length for starting sequence: #{starting_sequence}"
        end
      end
    end
  end
end