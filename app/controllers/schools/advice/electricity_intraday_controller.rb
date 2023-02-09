module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      def insights
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def analysis_dates
        start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_years_data: one_years_data?(start_date, end_date),
          recent_data: recent_data?(end_date),
          months_analysed: months_analysed(start_date, end_date)
        )
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
