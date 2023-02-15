module Schools
  module Advice
    class HeatingControlController < AdviceBaseController
      def insights
      end

      def analysis
        @analysis_dates = analysis_dates
        @last_week_start_times = heating_control_service.last_week_start_times
        @estimated_savings = heating_control_service.estimated_savings
        @seasonal_analysis = heating_control_service.seasonal_analysis
        @enough_data_for_seasonal_analysis = heating_control_service.enough_data_for_seasonal_analysis?

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
