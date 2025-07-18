module Schools
  module AdvicePageBenchmarks
    class SchoolBenchmarkGenerator
      def initialize(advice_page:, school:, aggregate_school:)
        @advice_page = advice_page
        @school = school
        @aggregate_school = aggregate_school
      end

      def self.can_benchmark?(advice_page:)
        generator_for_advice_page(advice_page: advice_page).present?
      end

      def self.generator_for(advice_page:, school:, aggregate_school:)
        generator_class = generator_for_advice_page(advice_page: advice_page)
        return nil unless generator_class.present?
        generator_class.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)
      end

      private_class_method def self.generator_for_advice_page(advice_page:)
        case advice_page.key.to_sym
        when :baseload
          BaseloadBenchmarkGenerator
        when :electricity_long_term, :gas_long_term
          LongTermUsageBenchmarkGenerator
        when :electricity_out_of_hours, :gas_out_of_hours
          OutOfHoursUsageBenchmarkGenerator
        when :electricity_intraday
          PeakUsageBenchmarkGenerator
        when :thermostatic_control
          ThermostaticControlBenchmarkGenerator
        when :heating_control
          HeatingControlBenchmarkGenerator
        end
      end

      def perform
        unless school_has_fuel_type?
          # remove any old benchmarks generated when school may have had active meters for this fuel type
          @school.advice_page_school_benchmarks.where(advice_page: @advice_page).destroy_all
          return nil
        end

        begin
          benchmarked_as = benchmark_school
          @school_benchmark = @school.advice_page_school_benchmarks.find_or_create_by(advice_page: @advice_page)
          if benchmarked_as.nil?
            @school_benchmark.destroy
            return nil
          end
          @school_benchmark.update!(benchmarked_as: benchmarked_as)
          @school_benchmark
        rescue => e
          Rollbar.error(e, scope: :advice_page_benchmarks, school_id: @school.id, school: @school.name, advice_page: @advice_page.key)
        end
      end

      protected

      def aggregate_school_service
        ::AggregateSchoolService.new(@school, @aggregate_school)
      end

      def school_has_fuel_type?
        @advice_page.school_has_fuel_type?(@school)
      end

      def advice_page_fuel_type
        @advice_page.fuel_type&.to_sym
      end

      def benchmark_school
        nil
      end
    end
  end
end
