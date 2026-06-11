# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Benchmark < Base
        METRIC_CATEGORY = :energy_efficiency
        BENCHMARKS = [{ fuel_types: %i[electricity gas], metric_type: :out_of_hours },
                      { fuel_types: %i[electricity gas], metric_type: :long_term },
                      { fuel_types: %i[electricity],     metric_type: :baseload },
                      { fuel_types: %i[gas],             metric_type: :heating_control }].freeze
        private_constant :BENCHMARKS
        METRICS = BENCHMARKS.pluck(:metric_type).freeze

        def self.metric_names
          BENCHMARKS.flat_map do |benchmark|
            benchmark[:fuel_types].map do |fuel_type|
              [{ metric_category:,
                 metric_type: benchmark[:metric_type],
                 fuel_type: },
               benchmark[:fuel_types].length == 1 ? nil : fuel_type]
            end
          end
        end

        def metrics
          self.class.metric_names.map do |metric, advice_page_fuel_type|
            good_schools, number_of_schools = categorise(advice_page_fuel_type, metric[:metric_type])
            metric.merge(enough_data: !number_of_schools.zero?,
                         number_of_schools:,
                         value: good_schools)
          end
        end

        private

        def categorise(fuel_type, benchmark)
          key = [fuel_type, benchmark].compact.join('_')
          categories = SchoolGroups::CategoriseSchools.new(schools: visible_schools)
                                                      .categorise_schools_for_advice_page(AdvicePage.find_by(key:))
          [%i[exemplar_school benchmark_school].sum { |category| categories[category]&.count || 0 },
           categories.values.sum(&:count)]
        end
      end
    end
  end
end
