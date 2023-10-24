module Schools
  module Advice
    class TotalEnergyUseController < AdviceBaseController
      def insights
        @overview_data = Schools::ManagementTableService.new(@school).management_data

        if can_benchmark_electricity?
          @electricity_annual_usage = electricity_usage_service.annual_usage
          @electricity_benchmarked_usage = electricity_usage_service.benchmark_usage
        end

        if can_benchmark_gas?
          @gas_annual_usage = gas_usage_service.annual_usage
          @gas_benchmarked_usage = gas_usage_service.benchmark_usage
        end
      end

      def analysis
        @overview_data = Schools::ManagementTableService.new(@school).management_data

        @analysis_dates = analysis_dates
        @benchmark_chart = benchmark_chart

        if can_benchmark_electricity?
          @electricity_annual_usage = electricity_usage_service.annual_usage
          @electricity_vs_benchmark = electricity_usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
          @electricity_vs_exemplar = electricity_usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)
          @electricity_estimated_savings_vs_exemplar = electricity_usage_service.estimated_savings(versus: :exemplar_school)
          @electricity_estimated_savings_vs_benchmark = electricity_usage_service.estimated_savings(versus: :benchmark_school)
        end

        if can_benchmark_gas?
          @gas_annual_usage = gas_usage_service.annual_usage
          @gas_vs_benchmark = gas_usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
          @gas_vs_exemplar = gas_usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)
          @gas_estimated_savings_vs_exemplar = gas_usage_service.estimated_savings(versus: :exemplar_school)
          @gas_estimated_savings_vs_benchmark = gas_usage_service.estimated_savings(versus: :benchmark_school)
        end
      end

      private

      def can_benchmark_electricity?
        @school.has_electricity? && electricity_usage_service.enough_data?
      end

      def can_benchmark_gas?
        @school.has_gas? && gas_usage_service.enough_data?
      end

      def benchmark_chart
        return :benchmark_one_year if can_benchmark_gas? && can_benchmark_electricity?
        return :benchmark_electric_only_one_year_kwh if can_benchmark_electricity?
        return :benchmark_gas_only_one_year_kwh if can_benchmark_gas?
        nil
      end

      def advice_page_key
        :total_energy_use
      end

      def aggregate_meters
        [aggregate_school.aggregated_electricity_meters, aggregate_school.aggregated_heat_meters].compact
      end

      def analysis_start_date
        aggregate_meters.map { |meter| meter.amr_data.start_date }.max
      end

      def analysis_end_date
        aggregate_meters.map { |meter| meter.amr_data.end_date }.min
      end

      def gas_usage_service
        @gas_usage_service ||= usage_service(:gas)
      end

      def electricity_usage_service
        @electricity_usage_service ||= usage_service(:electricity)
      end

      def usage_service(fuel_type)
        Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
      end
    end
  end
end
