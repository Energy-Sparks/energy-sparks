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
    end
  end
end
