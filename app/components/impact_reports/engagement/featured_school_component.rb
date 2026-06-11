# frozen_string_literal: true

module ImpactReports
  module Engagement
    class FeaturedSchoolComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def override?
        @config&.feature_visible_for?(:engagement)
      end

      def override_school
        @config.engagement_school
      end

      def default_school
        @default_school ||= @school_group.scored_schools.first
      end

      def school
        override? ? override_school : default_school
      end

      def description
        override? ? @config.engagement_note : default_description
      end

      def default_description
        key = if activity_count.zero?
                'actions'
              else
                action_count.zero? ? 'activities' : 'both'
              end

        # i18n-tasks-use t('school_groups.impact.engagement.featured.description.actions')
        # i18n-tasks-use t('school_groups.impact.engagement.featured.description.activities')
        # i18n-tasks-use t('school_groups.impact.engagement.featured.description.both')

        impact_t("engagement.featured.description.#{key}",
                 school: school.name,
                 activities: impact_t('engagement.featured.activities', count: activity_count),
                 actions: impact_t('engagement.featured.actions', count: action_count))
      end

      def now
        @now ||= Time.zone.now
      end

      def twelve_months_ago
        @twelve_months_ago ||= now - 12.months
      end

      def activity_count
        @activity_count ||= school.activities
                                  .between(twelve_months_ago, now)
                                  .count
      end

      def action_count
        @action_count ||= school.observations
                                .intervention
                                .between(twelve_months_ago, now)
                                .count
      end

      def podium
        @podium ||= Podium.create(school: school, scoreboard: @school_group)
      end

      def image
        @config.engagement_image.attached? ? @config.engagement_image : 'pupil-carbon.jpg'
      end

      def render?
        override? ? override_school : (default_school && podium.school_has_points?)
      end
    end
  end
end
