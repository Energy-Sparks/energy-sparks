module Schools
  module Advice
    class ThermostaticControlController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_thermostatic_control_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :thermostatic_control
      end
    end
  end
end
