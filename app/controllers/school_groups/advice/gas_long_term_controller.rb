module SchoolGroups
  module Advice
    class GasLongTermController < BaseLongTermController
      private

      def advice_page_key
        :gas_long_term
      end

      def report_key
        :change_in_gas_since_last_year
      end

      def report_class
        Comparison::ChangeInGasSinceLastYear
      end

      def alert_class_name
        'AlertGasAnnualVersusBenchmark'
      end

      def load_data
        report_class.for_schools(@schools).where.not(temperature_adjusted_percent: nil)
             .order(temperature_adjusted_percent: :asc)
      end
    end
  end
end
