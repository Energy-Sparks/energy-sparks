module Schools
  module Advice
    class GasRecentChangesController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_gas_recent_changes_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
