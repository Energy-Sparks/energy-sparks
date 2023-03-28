module Schools
  module Advice
    class HeatingControlController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]

      def insights
        @last_week_start_times = heating_control_service.last_week_start_times
        @estimated_savings = heating_control_service.estimated_savings
        @percentage_of_annual_gas = heating_control_service.percentage_of_annual_gas
        @enough_data_for_seasonal_analysis = heating_control_service.enough_data_for_seasonal_analysis?
        if @enough_data_for_seasonal_analysis
          @seasonal_analysis = heating_control_service.seasonal_analysis
          @warm_weather_on_days_rating = heating_control_service.warm_weather_on_days_rating
          @benchmark_warm_weather_days = heating_control_service.benchmark_warm_weather_days
        end
      end

      def analysis
        @analysis_dates = analysis_dates
        @last_week_start_times = heating_control_service.last_week_start_times
        @estimated_savings = heating_control_service.estimated_savings
        @percentage_of_annual_gas = heating_control_service.percentage_of_annual_gas

        @enough_data_for_seasonal_analysis = heating_control_service.enough_data_for_seasonal_analysis?
        if @enough_data_for_seasonal_analysis
          @seasonal_analysis = heating_control_service.seasonal_analysis
          @warm_weather_on_days_rating = heating_control_service.warm_weather_on_days_rating
        end

        @multiple_meters = heating_control_service.multiple_meters?
        if @multiple_meters
          @meters = heating_control_service.meters.sort_by(&:display_name)
          @date_ranges_by_meter = heating_control_service.date_ranges_by_meter
        end
      end

      private

      def advice_page_key
        :heating_control
      end

      def create_analysable
        heating_control_service
      end

      def heating_control_service
        @heating_control_service ||= HeatingControlService.new(@school, aggregate_school)
      end
    end
  end
end
