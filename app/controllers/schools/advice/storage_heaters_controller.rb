# frozen_string_literal: true

module Schools
  module Advice
    class StorageHeatersController < AdviceBaseController
      before_action :load_dashboard_alerts, only: %i[insights analysis learn_more]
      before_action :set_seasonal_analysis, only: %i[insights analysis]
      before_action :set_annual_usage_breakdown, only: %i[insights analysis]
      before_action :set_usage_categories, only: %i[insights analysis]
      before_action :set_heating_thermostatic_analysis, only: %i[insights analysis]

      def insights; end

      def analysis
        @holiday_usage = holiday_usage_calculation_service.school_holiday_calendar_comparison
      end

      private

      def create_analysable
        annual_usage_breakdown_service
      end

      def set_heating_thermostatic_analysis
        @heating_thermostatic_analysis = build_heating_thermostatic_analysis
      end

      def build_heating_thermostatic_analysis
        ::Heating::HeatingThermostaticAnalysisService.new(
          meter_collection: aggregate_school,
          fuel_type: :storage_heater
        ).create_model
      end

      def set_annual_usage_breakdown
        @annual_usage_breakdown = build_annual_usage_breakdown
      end

      def build_annual_usage_breakdown
        annual_usage_breakdown_service.usage_breakdown
      end

      def annual_usage_breakdown_service
        @annual_usage_breakdown_service ||= ::Usage::UsageBreakdownService.new(
          meter_collection: aggregate_school,
          fuel_type: :storage_heater
        )
      end

      def holiday_usage_calculation_service
        ::Usage::HolidayUsageCalculationService.new(
          aggregate_meter,
          aggregate_school.holidays
        )
      end

      def aggregate_meter
        aggregate_school.storage_heater_meter
      end

      def set_seasonal_analysis
        @seasonal_analysis = build_seasonal_analysis
      end

      def build_seasonal_analysis
        ::Heating::SeasonalControlAnalysisService.new(meter_collection: aggregate_school,
                                                      fuel_type: :storage_heater).seasonal_analysis
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html",
                                             case_study_1: "/case_studies/3/download?locale=#{I18n.locale}",
                                             case_study_2: "/case_studies/9/download?locale=#{I18n.locale}").html_safe
      end

      def advice_page_key
        :storage_heaters
      end

      def set_usage_categories
        @usage_categories = %i[holiday weekend school_day_open school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end
    end
  end
end
