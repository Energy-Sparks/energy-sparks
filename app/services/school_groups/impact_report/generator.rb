# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      def initialize(school_group)
        @import_report = ImpactReport.new(school_group)
        # debugger
      end

      def metrics
        [Overview, Engagement, PotentialSavings].lazy.flat_map do |metric_category|
          metric_category.new(@import_report).metrics
        end
      end
    end
  end
end
