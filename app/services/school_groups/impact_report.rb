# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    attr_reader :school_group

    def initialize(school_group)
      @school_group = school_group
    end

    def visible_schools
      @visible_schools ||= school_group.assigned_schools.visible
    end

    def data_visible_schools
      @data_visible_schools ||= school_group.assigned_schools.data_visible
    end

    delegate :count, to: :visible_schools, prefix: true
    delegate :count, to: :data_visible_schools, prefix: true

    def generated_at
      @generated_at ||= Time.zone.now
    end

    def last_month
      generated_at - 1.month
    end

    def twelve_months_ago
      @twelve_months_ago ||= generated_at - 12.months
    end

    def three_months_ago
      @three_months_ago ||= generated_at - 3.months
    end

    def overview
      @overview ||= Overview.new(self)
    end

    def energy_efficiency
      @energy_efficiency ||= EnergyEfficiency.new(self)
    end

    def engagement
      @engagement ||= Engagement.new(self)
    end

    def potential_savings
      @potential_savings ||= PotentialSavings.new(self)
    end

    def value(category, type)
      category = send(category)
      if category.respond_to?(:value)
        category.value(type)
      else
        category.public_send(type)
      end
    end

    def number_of_schools(category, type)
      send(category).number_of_schools(type)
    end

    def metrics
      %i[overview engagement potential_savings].flat_map do |metric_category|
        send(metric_category).metrics
      end
    end

    class Base
      attr_reader :impact_report

      def initialize(impact_report)
        @impact_report = impact_report
      end

      def metrics
        metric_names.map do |fuel_type, metric_type|
          { enough_data: enough_data?(fuel_type, metric_type),
            metric_category:,
            metric_type:,
            number_of_schools: number_of_schools(metric_type),
            fuel_type:,
            value: value(fuel_type, metric_type) }
        end
      end

      delegate :school_group, :visible_schools, :data_visible_schools, :generated_at, :twelve_months_ago,
               :three_months_ago, to: :impact_report

      private

      def enough_data?(*)
        true
      end

      def number_of_schools(*)
        @impact_report.visible_schools_count
      end

      def value(_fuel_type, metric_type)
        send(metric_type)
      end
    end

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
