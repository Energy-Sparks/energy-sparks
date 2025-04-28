module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        peak_usage_service = create_analysable
        @average_peak_kw = peak_usage_service.average_peak_kw
        @peak_kw_usage_percentage_change = peak_usage_service.percentage_change_in_peak_kw
        @benchmarked_usage = peak_usage_service.benchmark_peak_usage
        @peak_usage_service_date_range = peak_usage_service.date_range
      end

      def analysis
        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school_service, advice_page_fuel_type)
      end

      private

      def create_analysable
        Schools::Advice::PeakUsageService.new(@school, aggregate_school_service)
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
