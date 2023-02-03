module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      include Measurements

      def insights
      end

      def analysis
        @meters = @school.filterable_meters.electricity
        @chart_config = setup_chart_config
      end

      private

      def setup_chart_config
        {
          weekly: :calendar_picker_electricity_week_example_comparison_chart,
          daily: :calendar_picker_electricity_day_example_comparison_chart,
          earliest_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.start_date,
          last_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.end_date,
        }
      end

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
