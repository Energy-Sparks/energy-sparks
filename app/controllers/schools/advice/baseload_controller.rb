module Schools
  module Advice
    class BaseloadController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]

      def insights
        @aggregate_school_service = aggregate_school_service
        @service = baseload_service
      end

      def analysis
        @service = baseload_service
        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school_service, advice_page_fuel_type, include_whole_school: false)
      end

      private

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
