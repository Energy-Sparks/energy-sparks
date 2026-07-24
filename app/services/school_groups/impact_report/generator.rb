# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      GENERATORS = [Overview, Engagement, PotentialSavings, AnnualSaving, Benchmark, Targets, OutOfHours,
                    Holiday].freeze
      private_constant :GENERATORS

      def self.metric_names = GENERATORS.flat_map { |generator| generator.metric_names.map(&:first) }

      def initialize(school_group)
        @school_group = school_group
        @visible_schools = @school_group.assigned_schools.visible
      end

      def create_metrics!
        run = ::ImpactReport::Run.create!(school_group: @school_group, visible_schools: @visible_schools.count,
                                          run_date: Date.current)
        metrics.each do |attributes|
          run.metrics.create!(**attributes)
        rescue StandardError => e
          EnergySparks::Log.exception(e, school_group: @school_group.slug, attributes:)
        end
      end

      private

      def metrics
        GENERATORS.lazy.flat_map { |metric_category| metric_category.new(@school_group, @visible_schools).metrics }
      end
    end
  end
end
