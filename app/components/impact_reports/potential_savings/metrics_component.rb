# frozen_string_literal: true

module ImpactReports
  module PotentialSavings
    class MetricsComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
      def render?
        true
      end
    end
  end
end
