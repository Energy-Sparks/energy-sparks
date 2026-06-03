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

    class Base
      attr_reader :impact_report

      def initialize(impact_report)
        @impact_report = impact_report
      end

      delegate :school_group, :visible_schools, :data_visible_schools, :generated_at, :twelve_months_ago,
               :three_months_ago, to: :impact_report
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
