module Schools
  module Advice
    class ElectricityCostsController < BaseCostsController
      private

      def set_meters
        @meters = @school.meters.active.electricity
      end

      def aggregate_meter
        aggregate_school.aggregated_electricity_meters
      end

      def set_one_year_breakdown_chart
        dates = analysis_dates
        days_of_data = dates.end_date - dates.start_date
        case days_of_data
        when 1..13
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown_group_by_day
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown_group_by_day
        when 14..79
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown_group_by_week
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown_group_by_week
        else
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown
        end
      end

      def advice_page_key
        :electricity_costs
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
