module Schools
  module Advice
    class ElectricityLongTermController < BaseLongTermController
      before_action :load_dashboard_alerts, only: [:insights]

      private

      def fuel_type
        :electricity
      end

      def advice_page_key
        :electricity_long_term
      end

      def aggregate_meter
        aggregate_school.aggregated_electricity_meters
      end
    end
  end
end
