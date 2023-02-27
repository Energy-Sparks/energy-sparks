module Schools
  module Advice
    class HotWaterController < AdviceBaseController
      def insights
        @gas_hot_water = build_gas_hot_water
      end

      def analysis
        @gas_hot_water = build_gas_hot_water
      end

      private

      def create_analysable
        gas_hot_water_service
      end

      def build_gas_hot_water
        gas_hot_water_service.create_model
      end

      def gas_hot_water_service
        @gas_hot_water_service ||= HotWater::GasHotWaterService.new(meter_collection: aggregate_school)
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :hot_water
      end
    end
  end
end
