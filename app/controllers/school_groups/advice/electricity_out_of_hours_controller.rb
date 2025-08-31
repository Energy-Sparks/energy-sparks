module SchoolGroups
  module Advice
    class ElectricityOutOfHoursController < BaseOutOfHoursController
      private

      def advice_page_key
        :electricity_out_of_hours
      end

      def report_key
        :annual_electricity_out_of_hours_use
      end

      def report_class
        Comparison::AnnualElectricityOutOfHoursUse
      end

      def alert_class_name
        'AlertOutOfHoursElectricityUsage'
      end
    end
  end
end
