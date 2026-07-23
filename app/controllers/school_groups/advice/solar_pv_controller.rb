# frozen_string_literal: true

module SchoolGroups
  module Advice
    class SolarPvController < BaseAdviceWithComparisonController
      before_action :set_benefit_report, only: %i[insights analysis]

      def insights
        @insight_table_headers = insight_table_headers
        @benefit_table_headers = insight_benefit_table_headers
      end

      def analysis
        @solar_generation_summary_headers = Comparison::SolarGenerationSummary.report_headers
        @benefit_table_headers = Comparison::SolarPvBenefitEstimate.report_headers
      end

      private

      def set_benefit_report
        @benefit_report = Comparison::Report.find_by!(key: :solar_pv_benefit_estimate)
        @benefit_report_results = Comparison::SolarPvBenefitEstimate.for_schools(@schools).with_data.sort_default
      end

      def insight_table_headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('analytics.benchmarking.configuration.column_headings.solar_mains_consume'),
          t('analytics.benchmarking.configuration.column_headings.solar_self_consume')
        ]
      end

      def insight_benefit_table_headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
          t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
        ]
      end

      def advice_page_key
        :solar_pv
      end

      def report_key
        :solar_generation_summary
      end

      def load_data
        Comparison::SolarGenerationSummary.for_schools(@schools).with_data.sort_default
      end

      def breadcrumbs
        build_breadcrumbs([
                            { name: I18n.t('advice_pages.breadcrumbs.root'),
                              href: school_group_advice_path(@school_group) },
                            { name: I18n.t('advice_pages.solar_pv.has_solar_pv.page_title') }
                          ])
      end
    end
  end
end
