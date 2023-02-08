module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      def insights
      end

      def analysis
        @meters = @school.filterable_meters.gas
        @chart_config = setup_chart_config
      end

      private

      def setup_chart_config
        {
          earliest_reading:  aggregate_school.aggregate_meter(:gas).amr_data.start_date,
          last_reading:  aggregate_school.aggregate_meter(:gas).amr_data.end_date,
        }
      end

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
