module Schools
  module Advice
    class GasOutOfHoursController < BaseOutOfHoursController
      before_action :load_dashboard_alerts, only: [:insights, :analysis]

      private

      def fuel_type
        :gas
      end

      def advice_page_key
        :gas_out_of_hours
      end
    end
  end
end
