# frozen_string_literal: true

module Schools
  module Advice
    class SolarPvController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        if @school.has_solar_pv?
          @existing_benefits = build_existing_benefits
        else
          @potential_benefits_estimator = build_potential_benefits
        end
      end

      def analysis
        if @school.has_solar_pv?
          @existing_benefits = build_existing_benefits
        else
          @potential_benefits_estimator = build_potential_benefits
        end
      end

      private

      def create_analysable
        OpenStruct.new(
          enough_data?: enough_data?
        )
      end

      def enough_data?
        @school.has_solar_pv? || potential_benefits_service.enough_data?
      end

      def build_existing_benefits
        existing_benefits_service.create_model
      end

      def existing_benefits_service
        @existing_benefits_service ||= ::SolarPhotovoltaics::ExistingBenefitsService.new(
          meter_collection: aggregate_school
        )
      end

      def build_potential_benefits
        potential_benefits_service.create_model
      end

      def potential_benefits_service
        @potential_benefits_service ||= ::SolarPhotovoltaics::PotentialBenefitsEstimatorService.new(
          meter_collection: aggregate_school,
          asof_date: @analysis_dates.end_date
        )
      end

      def set_insights_next_steps
        return if @school.has_solar_pv?

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

      def advice_page_fuel_type
        :electricity
      end

      def advice_page_key
        :solar_pv
      end
    end
  end
end
