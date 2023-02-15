module Schools
  module Advice
    class SolarPvController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def set_page_title
        @advice_page_title = t("advice_pages.#{@advice_page.key}.#{action_name}.#{section_key}.title")
      end

      def section_key
        @school.has_solar_pv? ? :has_solar_pv : :no_solar_pv
      end

      def check_has_fuel_type
        # Skip fuel type check here as there are two versions of the solar pv page:
        # one version for when the school has solar pv, the other for when they don’t.
        true
      end

      def advice_page_key
        :solar_pv
      end
    end
  end
end
