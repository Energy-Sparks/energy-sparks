# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class Benchmark < Base
        def self.metric_name(benchmark, type)
          [benchmark, type].join('_').to_sym
        end

        BENCHMARKS = [[%i[electricity gas], :out_of_hours],
                      [%i[electricity gas], :long_term],
                      [[:electricity], :baseload],
                      [[:gas], :heating_control]].freeze
        BENCHMARK_TYPES = %i[exemplar well_managed].freeze
        private_constant :BENCHMARKS, :BENCHMARK_TYPES
        METRICS = BENCHMARKS.flat_map do |_fuel_types, benchmark|
          BENCHMARK_TYPES.map { |type| metric_name(benchmark, type) }
        end

        def metrics
          BENCHMARKS.flat_map do |fuel_types, benchmark|
            fuel_types.flat_map do |fuel_type|
              exemplar, well_managed, number_of_schools =
                categorise(fuel_types.length == 1 ? nil : fuel_type, benchmark)
              [metric(fuel_type, benchmark, :exemplar, number_of_schools, exemplar),
               metric(fuel_type, benchmark, :well_managed, number_of_schools, well_managed)]
            end
          end
        end

        private

        def metric(fuel_type, benchmark, type, number_of_schools, value)
          { enough_data: !number_of_schools.zero?,
            fuel_type:,
            metric_category:,
            metric_type: self.class.metric_name(benchmark, type),
            number_of_schools:,
            value: }
        end

        def metric_category
          :energy_efficiency
        end

        def categorise(fuel_type, benchmark)
          key = [fuel_type, benchmark].compact.join('_')
          categories = SchoolGroups::CategoriseSchools.new(schools: @impact_report.visible_schools)
                                                      .categorise_schools_for_advice_page(AdvicePage.find_by(key:))
          %i[exemplar_school benchmark_school].map { |category| categories[category]&.count || 0 } +
            [categories.values.sum(&:count)]
        end
      end
    end
  end
end
