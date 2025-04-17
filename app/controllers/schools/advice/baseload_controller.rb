module Schools
  module Advice
    class BaseloadController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]

      def insights
        @cache_view = true
        @aggregate_school_service = aggregate_school_service
        @service = baseload_service
        # @current_baseload = current_baseload
        # @benchmarked_baseload = baseload_service.benchmark_baseload
        # @saving_through_1_kw_reduction_in_baseload = baseload_service.saving_through_1_kw_reduction_in_baseload
      end

      def analysis
        @multiple_meters = baseload_service.multiple_electricity_meters?
        @average_baseload_kw = baseload_service.average_baseload_kw
        @average_baseload_kw_benchmark = baseload_service.average_baseload_kw_benchmark
        @baseload_usage = baseload_service.annual_baseload_usage
        @benchmark_usage = baseload_service.baseload_usage_benchmark
        @estimated_savings_vs_benchmark = baseload_service.estimated_savings(versus: :benchmark_school)
        @estimated_savings_vs_exemplar = baseload_service.estimated_savings(versus: :exemplar_school)
        @annual_average_baseloads = baseload_service.annual_average_baseloads
        if @multiple_meters
          @baseload_meter_breakdown = baseload_service.baseload_meter_breakdown
          @baseload_meter_breakdown_total = baseload_service.meter_breakdown_table_total
          @meter_selection = Charts::MeterSelection.new(@school, aggregate_school, advice_page_fuel_type, include_whole_school: false)
        end

        # need at least a years worth of data for this analysis
        if @analysis_dates.one_years_data?
          @seasonal_variation = baseload_service.seasonal_variation
          @seasonal_variation_by_meter = baseload_service.seasonal_variation_by_meter
          @intraweek_variation = baseload_service.intraweek_variation
          @intraweek_variation_by_meter = baseload_service.intraweek_variation_by_meter
        end
      end

      private

      def aggregate_meter
        @aggregate_meter ||= aggregate_school.aggregated_electricity_meters
      end

      def set_economic_tariffs_change_caveats
        @economic_tariffs_change_caveats = true
      end

      # def build_economic_tariffs_change_caveats
      #  Costs::EconomicTariffsChangeCaveatsService.new(
      #    meter_collection: aggregate_school, fuel_type: @advice_page.fuel_type.to_sym
      #  ).calculate_economic_tariff_changed
      # end

      # Should align with BaseloadCalculationService
      def create_analysable
        days = Baseload::BaseService::DEFAULT_DAYS_OF_DATA_REQUIRED
        enough_data = @analysis_dates.at_least_x_days_data?(days)
        date = enough_data ? nil : @analysis_dates.date_when_enough_data_available(days)
        ActiveSupport::OrderedOptions.new.merge(
          enough_data?: enough_data,
          data_available_from: date
        )
      end

      def baseload_service
        @baseload_service ||= Schools::Advice::BaseloadService.new(@school, aggregate_school_service)
      end

      def advice_page_key
        :baseload
      end
    end
  end
end
