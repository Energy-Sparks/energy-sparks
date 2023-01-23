module Schools
  module Advice
    class StorageHeatersController < AdviceController
      include AdvicePages

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
