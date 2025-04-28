# frozen_string_literal: true

module Schools
  module Advice
    class BaseMeterBreakdownController < AdviceBaseController
      before_action :redirect_if_single_meter
      before_action :set_meters_and_usage_breakdown, only: %i[insights analysis]

      def insights; end

      def analysis; end

      private

      def set_meters_and_usage_breakdown
        @meters_for_breakdown = sorted_meters_for_breakdown
        @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
        # only those meters included in the breakdown, will exclude any old/obsolete meters
        @annual_usage_breakdown_meters = @meters_for_breakdown.select do |mpan_mprn, _|
          @annual_usage_meter_breakdown.meters.include?(mpan_mprn)
        end
      end

      def create_analysable
        days_of_data = (@analysis_dates.end_date - @analysis_dates.start_date).to_i
        OpenStruct.new(
          enough_data?: days_of_data >= 7,
          data_available_from: nil
        )
      end

      def redirect_if_single_meter
        redirect_to school_advice_path(@school) unless @school.multiple_meters?(fuel_type)
      end

      def sorted_meters_for_breakdown
        meters = aggregate_school.underlying_meters(advice_page_fuel_type)
        meters.sort_by(&:mpan_mprn).index_by(&:mpan_mprn)
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school_service, fuel_type)
      end
    end
  end
end
