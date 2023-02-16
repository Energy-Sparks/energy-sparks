module Schools
  module Advice
    class SolarPvController < AdviceBaseController
      def insights
        if @school.has_solar_pv?
          @existing_benefits = build_existing_benefits
        else
          @potential_benefits_estimator = build_potential_benefits
        end
      end

      def analysis
        if @school.has_solar_pv?
          @analysis_dates = analysis_dates
          @existing_benefits = build_existing_benefits
        else
          @potential_benefits_estimator = build_potential_benefits
        end
      end

      private

      def build_existing_benefits
        ::SolarPhotovoltaics::ExistingBenefitsService.new(
          meter_collection: aggregate_school
        ).create_model
      end

      def build_potential_benefits
        ::SolarPhotovoltaics::PotentialBenefitsEstimatorService.new(
          meter_collection: aggregate_school,
          asof_date: analysis_end_date
        ).create_model
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.#{section_key}.insights.next_steps_html").html_safe
      end

      def set_page_subtitle
        @advice_page_subtitle = t("advice_pages.#{advice_page_key}.#{section_key}.#{action_name}.title")
      end

      def set_page_title
        @advice_page_title = t("advice_pages.#{advice_page_key}.#{section_key}.page_title")
      end

      def section_key
        @school.has_solar_pv? ? :has_solar_pv : :no_solar_pv
      end

      def check_has_fuel_type
        # Skip fuel type check here as there are two versions of the solar pv page:
        # one version for when the school has solar pv, the other for when they don’t.
        true
      end

      def advice_page_fuel_type
        :electricity
      end

      def advice_page_key
        :solar_pv
      end
    end
  end
end
