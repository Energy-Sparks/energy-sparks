module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_electricity_out_of_hours_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
