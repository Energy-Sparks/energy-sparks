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

    # Will move these out into seperate files at some point
    class Overview < Base
      def users
        # do we want cluster users?
        cluster_users = User.joins(:cluster_schools_users).where(cluster_schools_users: { school_id: visible_schools })

        User.where(school: visible_schools)
            .or(User.where(school_group: school_group))
            .or(User.where(id: cluster_users))
            .distinct
      end

      delegate :count, to: :users, prefix: true

      def users_logged_in_recently
        users.recently_logged_in(three_months_ago).count
      end

      def pupils
        visible_schools.sum(:number_of_pupils)
      end

      def funded_places
        3
      end

      def funded_places_value
        1500
      end

      # schools enrolled in the last 12 months
      def enrolled_schools
        school_group
          .onboardings_for_group
          .joins(:events)
          .where(
            school_onboarding_events: {
              event: SchoolOnboardingEvent.events[:onboarding_complete],
              created_at: twelve_months_ago..
            }
          )
          .distinct
          .count
      end

      # schools still enrolling
      def enrolling_schools
        school_group.onboardings_for_group.incomplete.count
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
          .between(twelve_months_ago, generated_at)
          .joins(:school)
          .merge(visible_schools)
          .count
      end

      def actions
        Observation
          .intervention
          .between(twelve_months_ago, generated_at)
          .joins(:school)
          .merge(visible_schools)
          .count
      end

      def points
        Observation
          .between(twelve_months_ago, generated_at)
          .joins(:school)
          .merge(visible_schools)
          .sum(:points)
      end

      def featured_school
        @featured_school ||= School
                             .joins(:observations)
                             .merge(Observation.between(twelve_months_ago, generated_at))
                             .merge(visible_schools)
                             .select('schools.*, SUM(observations.points) AS total_points')
                             .group('schools.id')
                             .order(total_points: :desc)
                             .first
      end

      def featured_school_activities
        featured_school
          .activities
          .between(twelve_months_ago, generated_at)
          .count
      end

      def featured_school_actions
        featured_school
          .observations
          .intervention
          .between(twelve_months_ago, generated_at)
          .count
      end

      def programmes
        Programme
          .completed
          .where(created_at: twelve_months_ago..)
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
