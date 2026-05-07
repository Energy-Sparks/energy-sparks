# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Overview < Base
      def visible_schools
        @impact_report.visible_schools_count
      end

      def data_visible_schools
        @impact_report.data_visible_schools_count
      end

      def users
        users_scope.count
      end

      def active_users
        users_scope.recently_logged_in(three_months_ago).count
      end

      def pupils
        @impact_report.visible_schools.sum(:number_of_pupils)
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

      private

      def users_scope
        schools = @impact_report.visible_schools
        # do we want cluster users?
        cluster_users = User.joins(:cluster_schools_users).where(cluster_schools_users: { school_id: schools })

        User.where(school: schools)
            .or(User.where(school_group:))
            .or(User.where(id: cluster_users))
            .distinct
      end

      def metric_names
        ::ImpactReport::Metric::OVERVIEW_METRICS.map { |metric| [nil, metric] }
      end

      def metric_category
        :overview
      end
    end
  end
end
