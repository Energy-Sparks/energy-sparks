module Schools
  module Advice
    class HotWaterController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_hot_water_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :hot_water
      end
    end
  end
end
