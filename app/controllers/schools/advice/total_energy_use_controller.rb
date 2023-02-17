module Schools
  module Advice
    class TotalEnergyUseController < AdviceBaseController
      def insights
        @overview_data = Schools::ManagementTableService.new(@school).management_data

        if @school.has_electricity? && electricity_usage_service.enough_data?
          @electricity_annual_usage = electricity_usage_service.annual_usage
          @electricity_benchmarked_usage = benchmarked_usage(electricity_usage_service, @electricity_annual_usage.kwh)
        end

        if @school.has_gas? && gas_usage_service.enough_data?
          @gas_annual_usage = gas_usage_service.annual_usage
          @gas_benchmarked_usage = benchmarked_usage(gas_usage_service, @gas_annual_usage.kwh)
        end
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

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

      def benchmarked_usage(usage_service, annual_usage_kwh)
        annual_usage_kwh_benchmark = usage_service.annual_usage_kwh(compare: :benchmark_school)
        annual_usage_kwh_exemplar = usage_service.annual_usage_kwh(compare: :exemplar_school)

        OpenStruct.new(
          category: categorise_school_vs_benchmark(annual_usage_kwh, annual_usage_kwh_benchmark, annual_usage_kwh_exemplar),
          annual_usage_kwh: annual_usage_kwh,
          annual_usage_kwh_benchmark: annual_usage_kwh_benchmark,
          annual_usage_kwh_exemplar: annual_usage_kwh_exemplar
        )
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
