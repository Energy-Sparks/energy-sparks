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
        METRICS = BENCHMARKS.map(&:second)

        def metrics
          BENCHMARKS.flat_map do |fuel_types, metric_type|
            fuel_types.map do |fuel_type|
              good_schools, number_of_schools = categorise(fuel_types.length == 1 ? nil : fuel_type, metric_type)
              { enough_data: !number_of_schools.zero?,
                fuel_type:,
                metric_category:,
                metric_type:,
                number_of_schools:,
                value: good_schools }
            end
          end
        end

        private

        def metric(fuel_type, metric_type, number_of_schools, value)
          { enough_data: !number_of_schools.zero?,
            fuel_type:,
            metric_category:,
            metric_type: benchmark,
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
          [%i[exemplar_school benchmark_school].sum { |category| categories[category]&.count || 0 },
           categories.values.sum(&:count)]
        end
      end
    end
  end
end
