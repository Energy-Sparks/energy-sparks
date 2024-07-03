module Schools
  module Advice
    class BaseMeterBreakdownController < AdviceBaseController
      before_action :redirect_if_single_meter

      def insights
        @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
        @meters_for_breakdown = sorted_meters_for_breakdown(@annual_usage_meter_breakdown)
      end

      def analysis
        @analysis_dates = analysis_dates
        @date_ranges_by_meter = date_ranges_by_meter
        @options_for_meter_select = options_for_meter_select
        @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
        @meters_for_breakdown = sorted_meters_for_breakdown(@annual_usage_meter_breakdown)
      end

      private

      def date_ranges_by_meter
        meters.each_with_object({}) do |analytics_meter, date_range_by_meter|
          end_date = analytics_meter.amr_data.end_date
          start_date = analytics_meter.amr_data.start_date
          meter = @school.meters.find_by_mpan_mprn(analytics_meter.mpan_mprn)
          date_range_by_meter[analytics_meter.mpan_mprn] = {
            meter: meter,
            start_date: start_date,
            end_date: end_date
          }
        end
      end

      def options_for_meter_select
        @school.meters.active.where(meter_type: fuel_type).sort_by(&:mpan_mprn)
      end

      def redirect_if_single_meter
        redirect_to school_advice_path(@school) unless @school.multiple_meters?(fuel_type)
      end

      def sorted_meters_for_breakdown(annual_usage_meter_breakdown)
        meters = @school.meters.where(mpan_mprn: annual_usage_meter_breakdown.meters).order(:mpan_mprn)
        meters.index_by(&:mpan_mprn)
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
      end
    end
  end
end
