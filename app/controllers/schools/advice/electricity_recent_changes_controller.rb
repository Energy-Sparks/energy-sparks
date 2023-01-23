module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_electricity_recent_changes_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
