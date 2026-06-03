# frozen_string_literal: true

module Schools
  module Advice
    class HeatingControlController < AdviceBaseController
      before_action :load_dashboard_alerts, only: %i[insights analysis]

      def insights
        @heating_control_service = heating_control_service
      end

      def analysis
        @heating_control_service = heating_control_service
        @meter_selection = Charts::MeterSelection.new(@school,
                                                      aggregate_school_service,
                                                      advice_page_fuel_type,
                                                      filter: :non_heating_only?,
                                                      date_window: 363,
                                                      include_whole_school: false)
      end

      private

      def advice_page_key
        :heating_control
      end

      def create_analysable
        heating_control_service
      end

      def heating_control_service
        @heating_control_service ||= HeatingControlService.new(@school, aggregate_school_service)
      end
    end
  end
end
