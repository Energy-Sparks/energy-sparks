module SchoolGroups
  module Advice
    class GasOutOfHoursController < BaseOutOfHoursController
      private

      def advice_page_key
        :gas_out_of_hours
      end

      def report_key
        :annual_gas_out_of_hours_use
      end

      def report_class
        Comparison::AnnualGasOutOfHoursUse
      end

      def alert_class_name
        'AlertOutOfHoursGasUsage'
      end
    end
  end
end
