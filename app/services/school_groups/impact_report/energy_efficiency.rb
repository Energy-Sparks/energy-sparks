# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class EnergyEfficiency < Base
      TYPES = %i[gbp co2 kwh].freeze
      private_constant :TYPES
      METRICS = %i[electricity gas].flat_map { |fuel| TYPES.map { |type| "#{fuel}_#{type}" } }.freeze

      def initialize(*)
        super
        @number_of_schools = {}
      end

      def total_gas_savings
        60_000
      end

      def total_gas_savings_schools
        4
      end

      def value(metric)
        sum(metric)
      end

      def number_of_schools(metric)
        @number_of_schools[metric] ||= savings(metric).count
      end

      def enough_data?(metric)
        number_of_schools(metric).positive?
      end

      def total_electricity_savings_gbp
        sum(:electricity_gbp)
      end

      def total_electricity_savings_co2
        sum(:electricity_co2)
      end

      def total_electricity_savings_gbp_schools
        savings(:electricity_gbp).count
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

      def featured_school
        @featured_school ||= visible_schools.sample
      end

      def featured_school_percentage_reduction
        30
      end

      private

      def savings(type)
        scope = if type.start_with?('gas_')
                  Comparison::ChangeInGasSinceLastYear
                else
                  Comparison::ChangeInElectricitySinceLastYear
                end
        suffix = suffix(type)
        scope.where("current_year_#{suffix} < previous_year_#{suffix}")
      end

      def sum(type)
        suffix = suffix(type)
        savings(type).sum("previous_year_#{suffix} - current_year_#{suffix}")
      end

      def suffix(type)
        type.start_with?('gas_') ? type.split('_').last : type
      end
    end
  end
end
