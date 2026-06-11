# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Overview < Base
        METRIC_CATEGORY = :overview
        METRICS = %i[visible_schools data_visible_schools users active_users pupils enrolled_schools
                     enrolling_schools].freeze

        private

        def value(metric)
          case metric[:metric_type]
          when :visible_schools
            visible_schools.count
          when :data_visible_schools
            data_visible_schools.count
          when :users
            users_scope.count
          when :active_users
            users_scope.recently_logged_in(three_months_ago).count
          when :pupils
            visible_schools.sum(:number_of_pupils)
          else
            send(metric[:metric_type])
          end
        end

        def three_months_ago = @three_months_ago ||= generated_at - 3.months

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
        def enrolling_schools = school_group.onboardings_for_group.incomplete.count

        def users_scope
          schools = visible_schools
          cluster_users = User.joins(:cluster_schools_users).where(cluster_schools_users: { school_id: schools })
          User.active.confirmed.where.not(role: :pupil)
              .where('school_id IN (:schools) OR school_group_id = :school_group OR users.id IN (:cluster_users)',
                     schools: schools.select(:id), school_group:, cluster_users: cluster_users.select(:id))
        end
      end
    end
  end
end
