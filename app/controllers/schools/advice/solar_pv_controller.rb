module Schools
  module Advice
    class SolarPvController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_solar_pv_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :solar_pv
      end
    end
  end
end
