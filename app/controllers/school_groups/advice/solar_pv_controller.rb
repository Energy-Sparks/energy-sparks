# frozen_string_literal: true

module SchoolGroups
  module Advice
    class SolarPvController < BaseAdviceWithComparisonController
      def insights
        @insight_table_headers = insight_table_headers
      end

      def analysis
        @solar_generation_summary_headers = Comparison::SolarGenerationSummary.report_headers
      end

      private

      def insight_table_headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('analytics.benchmarking.configuration.column_headings.solar_mains_consume'),
          t('analytics.benchmarking.configuration.column_headings.solar_self_consume')
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
