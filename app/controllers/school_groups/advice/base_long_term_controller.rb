module SchoolGroups
  module Advice
    class BaseLongTermController < BaseAdviceWithComparisonController
      def insights
        @comparison = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools_for_advice_page(@advice_page)
        @insight_table_headers = headers(groups: insight_header_groups)
        @report_colgroups = colgroups(groups: insight_header_groups)
      end

      def analysis
        alert_type = AlertType.find_by_class_name(alert_class_name)
        @alerts = alert_type ? SchoolGroups::Alerts.new(@schools).alerts(alert_type) : []
        @categorised_savings = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_savings(@advice_page, @alerts)
        @report_headers = headers
        @report_colgroups = colgroups
      end

      private

      def set_titles
        @page_title = t('page_title', scope: 'school_groups.advice_pages.long_term', fuel_type: @advice_page.fuel_type, default: nil)
      end

      def header_groups
        report_class.default_header_groups
      end

      def insight_header_groups
        [
          { label: '',
            headers: [I18n.t('analytics.benchmarking.configuration.column_headings.school')] },
          { label: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
            headers: [
              I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
              I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
            ] },
          { label: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            headers: [
              I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
              I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
            ] },
          { label: I18n.t('analytics.benchmarking.configuration.column_groups.gbp'),
            headers: [
              I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
              I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
            ] }
        ]
      end

      def load_data
        report_class.for_schools(@schools).with_data.by_percentage_change(:previous_year_electricity_kwh, :current_year_electricity_kwh)
      end
    end
  end
end
