# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Base
        UNITS = [nil].freeze
        FUEL_TYPES = [nil].freeze

        def self.metric_names
          self::METRICS.product(self::FUEL_TYPES, self::UNITS).map do |metric_type, fuel_type, unit|
            [{ metric_category:, metric_type:, fuel_type:, unit: }]
          end
        end

        private_class_method def self.metric_category = self::METRIC_CATEGORY

        def initialize(school_group, visible_schools)
          @school_group = school_group
          @visible_schools = visible_schools
        end

        def metrics
          self.class.metric_names.map do |metric,|
            number_of_schools = number_of_schools(metric)
            metric.merge(enough_data: enough_data?(number_of_schools),
                         number_of_schools:,
                         value: value(metric))
          end
        end

        private

        attr_reader :visible_schools, :school_group

        def enough_data?(*) = true

        def number_of_schools(*) = visible_schools.count

        def data_visible_schools = @data_visible_schools ||= @school_group.assigned_schools.data_visible

        def generated_at = @generated_at ||= Time.zone.now

        def twelve_months_ago = @twelve_months_ago ||= generated_at - 12.months
      end
    end
  end
end
