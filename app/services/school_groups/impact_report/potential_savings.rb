# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class PotentialSavings < Base
      def electricity_savings
        12_000
      end

      def solar_panels
        32_000
      end

      def solar_panels_schools
        7
      end

      def gas_savings
        11_000
      end

      def gas_savings_schools
        12
      end
    end
  end
end
