module Schools
  module Advice
    class StorageHeatersController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :storage_heaters
      end

      def advice_page_fuel_type
        :storage_heater
      end
    end
  end
end
