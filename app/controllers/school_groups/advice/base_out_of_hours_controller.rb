module SchoolGroups
  module Advice
    class BaseOutOfHoursController < BaseController
      include ComparisonTableGenerator

      before_action :run_report

      def insights
        @comparison = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools_for_advice_page(@advice_page)
        @insight_table_headers = insight_table_headers
      end

      def analysis
        alert_type = AlertType.find_by_class_name(alert_class_name)
        @alerts = alert_type ? SchoolGroups::Alerts.new(@schools).alerts(alert_type) : []
        @categorised_savings = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_savings(@advice_page, @alerts)
        @report_headers = report_class.default_headers
      end

      private

      def run_report
        @report = Comparison::Report.find_by!(key: report_key)
        @results = load_data
      end

      def insight_table_headers
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.school_day_open'),
          I18n.t('analytics.benchmarking.configuration.column_headings.school_day_closed'),
          I18n.t('analytics.benchmarking.configuration.column_headings.holiday'),
          I18n.t('analytics.benchmarking.configuration.column_headings.weekend'),
          I18n.t('analytics.benchmarking.configuration.column_headings.community'),
        ]
      end

      def index_params
        { benchmark: report_key, school_group_ids: [@school_group.id] }
      end

      def load_data
        report_class.for_schools(@schools).with_data.sort_default
      end
    end
  end
end
