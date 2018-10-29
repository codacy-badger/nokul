# frozen_string_literal: true

module Xokul
  module Yoksis
    module Units
      module_function

      def changes(day:, month:, year:)
        Connection.request(
          '/yoksis/units/changes', params: { day: day, month: month, year: year }
        )
      end

      def programs(sub_unit_id:)
        Connection.request(
          '/yoksis/units/programs', params: { sub_unit_id: sub_unit_id }
        )
      end

      def universities
        Connection.request '/yoksis/units/universities'
      end

      %i[
        subunits
        names
      ].each do |method|
        define_method(method) do |unit_id:|
          Connection.request(
            "/yoksis/units/#{method}", params: { unit_id: unit_id }
          )
        end
      end
    end
  end
end
