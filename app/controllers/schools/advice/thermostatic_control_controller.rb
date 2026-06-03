# frozen_string_literal: true

module Schools
  module Advice
    class ThermostaticControlController < AdviceBaseController
      def insights
        @heating_thermostatic_analysis = thermostatic_analysis_service.thermostatic_analysis
        @benchmark_thermostatic_control = thermostatic_analysis_service.benchmark_thermostatic_control
      end

      def analysis
        @heating_thermostatic_analysis = thermostatic_analysis_service.thermostatic_analysis
      end

      private

      def thermostatic_analysis_service
        @thermostatic_analysis_service ||= Schools::Advice::ThermostaticAnalysisService.new(@school, aggregate_school_service)
      end

      def create_analysable
        thermostatic_analysis_service
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :thermostatic_control
      end
    end
  end
end
