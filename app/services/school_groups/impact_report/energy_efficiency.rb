# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class EnergyEfficiency < Base
      def total_gas_savings
        60_000
      end

      def total_gas_savings_schools
        4
      end

      def total_electricity_savings
        86_000
      end

      def total_electricity_savings_schools
        3
      end

      def reduced_gas_emissions
        40_000
      end

      def reduced_gas_emissions_schools
        4
      end

      def reduced_electricity_emissions
        5000
      end

      def reduced_electricity_emissions_schools
        3
      end
    end
  end
end
