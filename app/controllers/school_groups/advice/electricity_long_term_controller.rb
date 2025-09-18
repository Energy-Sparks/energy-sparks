module SchoolGroups
  module Advice
    class ElectricityLongTermController < BaseLongTermController
      private

      def advice_page_key
        :electricity_long_term
      end

      def report_key
        :change_in_electricity_since_last_year
      end

      def report_class
        Comparison::ChangeInElectricitySinceLastYear
      end

      def alert_class_name
        'AlertElectricityAnnualVersusBenchmark'
      end

      def load_data
        report_class.for_schools(@schools).with_data.by_percentage_change(:previous_year_electricity_kwh, :current_year_electricity_kwh)
      end
    end
  end
end
