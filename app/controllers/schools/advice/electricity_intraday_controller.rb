module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      def insights
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def create_analysable
        OpenStruct.new(
          enough_data?: analysis_dates.one_years_data
        )
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
