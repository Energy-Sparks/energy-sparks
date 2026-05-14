# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      def initialize(school_group)
        @school_group = school_group
        @import_report = ImpactReport.new(school_group)
      end

      def create_metrics!
        run = ::ImpactReport::Run.create!(school_group: @school_group, run_date: Date.current)
        metrics.each { |attributes| run.metrics.create!(**attributes) }
      end

      private

      def metrics
        [Overview, Engagement, PotentialSavings, EnergyEfficiency, Benchmark, Targets, OutOfHours]
          .lazy.flat_map { |metric_category| metric_category.new(@import_report).metrics }
      end
    end
  end
end
