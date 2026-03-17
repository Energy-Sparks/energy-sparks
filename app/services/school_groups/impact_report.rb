module SchoolGroups
  class ImpactReport
    include ActionView::Helpers::NumberHelper

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

    def schools
      visible_schools.count
    end

    def schools_data_visible
      data_visible_schools.count
    end

    def generated_at
      Time.zone.now
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

    class Base
      attr_reader :impact_report

      def initialize(impact_report)
        @impact_report = impact_report
      end

      delegate :school_group,
               :visible_schools,
               :data_visible_schools,
               to: :impact_report
    end

    # Might move these out into seperate files at some point
    class Overview < Base
      def users
        school_group.users.count
      end

      def users_logged_in_recently
        school_group.users.recently_logged_in(3.months.ago).count
      end

      def pupils
        visible_schools.map(&:number_of_pupils).compact.sum
      end

      def funded_places
        3
      end

      def funded_places_value
        1500
      end

      def enrolling_schools
        school_group.onboardings_for_group.incomplete.count
      end

      def enrolled_schools
        2
      end
    end

    class EnergyEfficiency < Base
      def total_gas_savings
        60000
      end

      def total_gas_savings_schools
        4
      end

      def total_electricity_savings
        86000
      end

      def total_electricity_savings_schools
        3
      end

      def reduced_gas_emissions
        40000
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
    end

    class Engagement < Base
      def activities
        Activity
          .between(12.months.ago, Time.zone.now)
          .joins(:school)
          .merge(visible_schools)
          .count
      end

      def actions
        Observation
          .intervention
          .between(12.months.ago, Time.zone.now)
          .joins(:school)
          .merge(visible_schools)
          .count
      end

      def points
        Observation
          .between(12.months.ago, Time.zone.now)
          .joins(:school)
          .merge(visible_schools)
          .sum(:points)
      end

      def school
        @school ||= School
          .joins(:observations)
          .merge(Observation.between(12.months.ago, Time.zone.now))
          .merge(visible_schools)
          .select('schools.*, SUM(observations.points) AS total_points')
          .group('schools.id')
          .order('total_points DESC')
          .first
      end

      def school_activities
        school
          .activities
          .between(12.months.ago, Time.zone.now)
          .count
      end

      def school_actions
        school
          .observations
          .intervention
          .between(12.months.ago, Time.zone.now)
          .count
      end

      def programmes
        Programme
          .completed
          .where(created_at: 12.months.ago..)
          .joins(:school)
          .merge(visible_schools)
          .count
      end

      def targets
        SchoolTarget
          .currently_active
          .joins(:school)
          .merge(visible_schools)
          .count
      end
    end
  end
end
