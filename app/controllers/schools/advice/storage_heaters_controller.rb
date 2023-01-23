module Schools
  module Advice
    class StorageHeatersController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_storage_heaters_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :storage_heaters
      end
    end
  end
end
