module Schools
  module Advice
    class HotWaterController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :hot_water
      end
    end
  end
end
