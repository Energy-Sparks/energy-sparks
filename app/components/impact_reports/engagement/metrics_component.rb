# frozen_string_literal: true

module ImpactReports
  module Engagement
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def initialize(**)
        super
        raise_unless_run
      end

      def self.metric_category
        :engagement
      end

      # disabled for now
      def display_programmes?
        false
      end

      def cols
        %i[activities actions points targets]
          .map { |metric| engagement?(metric) }
          .count(true)
      end
    end
  end
end
