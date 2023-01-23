module Schools
  module Advice
    class BoilerControlController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_boiler_control_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :boiler_control
      end
    end
  end
end
