module Schools
  module AdvicePageBenchmarks
    class SchoolBenchmarkGenerator
      def initialize(advice_page:, school:, aggregate_school:)
        @advice_page = advice_page
        @school = school
        @aggregate_school = aggregate_school
      end

      def self.generator_for(advice_page:, school:, aggregate_school:)
        case advice_page.key.to_sym
        when :baseload
          BaseloadBenchmarkGenerator
        when :electricity_long_term, :gas_long_term
          LongTermUsageBenchmarkGenerator
        end
        return generator_class.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)
      end

      def perform
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

      def benchmark_school
        nil
      end
    end
  end
end
