# frozen_string_literal: true

module ImpactReports
  module Engagement
    class FeaturedSchoolComponent < ImpactReports::BaseComponent
      def override?
        @config&.feature_visible_for?(:engagement)
      end

      def school
        override? ? @config.engagement_school : default_school
      end

      def default_school
        @default_school ||= @school_group.scored_schools.first
      end

      def description
        override? ? @config.engagement_note : default_description
      end

      def default_description
        impact_t('engagement.featured.description',
                 school: school.name,
                 activities: activity_count,
                 actions: action_count)
      end

      def today
        @today ||= Time.zone.today
      end

      def twelve_months_ago
        @twelve_months_ago ||= today - 12.months
      end

      def activity_count
        @activity_count ||= school.activities
                                  .between(twelve_months_ago, today)
                                  .count
      end

      def action_count
        @action_count ||= school.observations
                                .intervention
                                .between(twelve_months_ago, today)
                                .count
      end

      def podium
        @podium ||= Podium.create(school: school, scoreboard: @school_group)
      end

      def image
        @config.engagement_image.attached? ? @config.engagement_image : 'pupil-carbon.jpg'
      end

      def render?
        school.present?
      end
    end
  end
end
