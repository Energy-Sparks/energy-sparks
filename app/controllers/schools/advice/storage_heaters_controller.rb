module Schools
  module Advice
    class StorageHeatersController < AdviceBaseController
      def insights
        @seasonal_analysis = build_seasonal_analysis
      end

      def analysis
      end

      private

      def build_seasonal_analysis
        Heating::SeasonalControlAnalysisService.new(meter_collection: aggregate_school, fuel_type: :storage_heater).seasonal_analysis
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :storage_heaters
      end
    end
  end
end
