module Schools
  module Advice
    class HeatingControlController < AdviceBaseController
      def insights
      end

      def analysis
        @multiple_meters = multiple_meters?
        @last_week_start_times = heating_control_service.last_week_start_times
        @estimated_savings = heating_control_service.estimated_savings
      end

      private

      def advice_page_key
        :heating_control
      end

      def multiple_meters?
        @school.meters.active.gas.count > 1
      end

      def heating_control_service
        @heating_control_service ||= HeatingControlService.new(@school, aggregate_school)
      end
    end
  end
end
