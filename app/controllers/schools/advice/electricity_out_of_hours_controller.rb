module Schools
  module Advice
    class ElectricityOutOfHoursController < BaseOutOfHoursController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]

      private

      def fuel_type
        :electricity
      end

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
