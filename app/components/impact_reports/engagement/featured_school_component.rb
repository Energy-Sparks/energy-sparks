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
        @default_school ||= @school_group
                            .scored_schools(recent_boundary: twelve_months_ago, academic_year: nil)
                            .top_by_recent_points
      end

      def school
        override? ? override_school : default_school
      end

      def description
        override? ? @config.engagement_note : default_description
      end

      def default_description
        impact_t('engagement.featured.description',
                 school: school.name,
                 count: school.recent_points)
      end

      def now
        @now ||= Time.zone.now
      end

      def twelve_months_ago
        @twelve_months_ago ||= now - 12.months
      end

      def podium_school
        school = @school_group.scored_schools.first # this is the same as school group dashboard
        school if school&.sum_points&.positive?
      end

      def podium
        @podium ||= Podium.create(school: podium_school, scoreboard: @school_group)
      end

      def image
        @config.engagement_image.attached? ? @config.engagement_image : 'pupil-carbon.jpg'
      end

      def render?
        override? ? override_school : (default_school && podium_school)
      end
    end
  end
end
