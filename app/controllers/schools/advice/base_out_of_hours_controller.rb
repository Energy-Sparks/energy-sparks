module Schools
  module Advice
    class BaseOutOfHoursController < AdviceBaseController
      before_action :set_usage_categories

      def insights
        @out_of_hours_usage_service = out_of_hours_usage_service
      end

      def analysis
        @out_of_hours_usage_service = out_of_hours_usage_service
        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school_service, advice_page_fuel_type, date_window: 363)
      end

      private

      def check_can_run_analysis
        @analysable = create_analysable
        render 'not_enough_data' and return unless @analysable.enough_data?
        set_analysis_dates
        @annual_usage_breakdown = out_of_hours_usage_service.annual_usage_breakdown
        render 'schools/advice/out_of_hours/no_usage' and return if @annual_usage_breakdown&.out_of_hours&.kwh&.zero?
      end

      def create_analysable
        out_of_hours_usage_service
      end

      def out_of_hours_usage_service
        @out_of_hours_usage_service = Schools::Advice::OutOfHoursUsageService.new(@school, aggregate_school_service, fuel_type)
      end

      def set_usage_categories
        @usage_categories = [:holiday, :weekend, :school_day_open, :school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end
    end
  end
end
