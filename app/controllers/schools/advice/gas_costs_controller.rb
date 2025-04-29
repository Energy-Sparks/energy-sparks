module Schools
  module Advice
    class GasCostsController < BaseCostsController
      private

      def set_meters
        @meters = @school.meters.active.gas
      end

      def aggregate_meter
        aggregate_school.aggregated_heat_meters&.original_meter
      end

      # FIXME keep to current, or change over?
      def set_one_year_breakdown_chart
        case @analysis_dates.days_of_data
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
        :gas_costs
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
