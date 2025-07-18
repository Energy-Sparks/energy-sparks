module Schools
  module Advice
    class GasOutOfHoursController < BaseOutOfHoursController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]
      before_action :set_heating_model_available, only: [:analysis]

      private

      def fuel_type
        :gas
      end

      def advice_page_key
        :gas_out_of_hours
      end

      def set_heating_model_available
        @heating_model_available = HeatingControlService.new(@school, aggregate_school_service).enough_data?
      end
    end
  end
end
