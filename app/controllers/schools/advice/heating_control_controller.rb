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

        @multiple_meters = multiple_meters?
        if @multiple_meters
          @meters = @school.meters.active.gas.sort_by(&:name_or_mpan_mprn)
          @date_ranges_by_meter = heating_control_service.date_ranges_by_meter
        end
      end

      private

      def analysis_dates
        start_date = aggregate_meter.amr_data.start_date
        end_date = aggregate_meter.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_year_before_end: end_date - 1.year,
          last_full_week_start_date: last_full_week_start_date(end_date),
          last_full_week_end_date: last_full_week_end_date(end_date),
          recent_data: recent_data?(end_date)
        )
      end

      #for charts that use the last full week
      def last_full_week_start_date(end_date)
        end_date.prev_year.end_of_week
      end

      #for charts that use the last full week
      def last_full_week_end_date(end_date)
        end_date.prev_week.end_of_week - 1
      end

      def advice_page_key
        :heating_control
      end

      def multiple_meters?
        @school.meters.active.gas.count > 1
      end

      def aggregate_meter
        aggregate_school.aggregated_heat_meters
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
