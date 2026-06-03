module SchoolGroups
  module Advice
    class BaseloadController < BaseAdviceWithComparisonController
      def insights
        @baseload_comparison = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools_for_advice_page(@advice_page)
        @insight_table_headers = insight_table_headers
      end

      def analysis
        alert_type = AlertType.find_by_class_name('AlertElectricityBaseloadVersusBenchmark')
        @baseload_alerts = alert_type ? SchoolGroups::Alerts.new(@schools).alerts(alert_type) : []
        @categorised_savings = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_savings(@advice_page, @baseload_alerts)
        @baseload_per_pupil_headers = Comparison::BaseloadPerPupil.report_headers
      end

      private

      def report_key
        :baseload_per_pupil
      end

      def insight_table_headers
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
          I18n.t('analytics.benchmarking.configuration.column_headings.average_baseload_kw'),
        ]
      end

      def advice_page_key
        :baseload
      end

      def load_data
        Comparison::BaseloadPerPupil.for_schools(@schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
      end
    end
  end
end
