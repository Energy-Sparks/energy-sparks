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
        @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
        @meters_for_breakdown = sorted_meters_for_breakdown(@annual_usage_meter_breakdown)
      end

      private

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
