module SchoolGroups
  module Advice
    class BaseloadController < BaseController
      include ComparisonTableGenerator
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs

      load_resource :school_group
      before_action :run_report

      def insights
        @baseload_comparison = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools_for_advice_page(@advice_page)
        @insight_table_headers = insight_table_headers
      end

      def analysis
        @baseload_benchmarks = SchoolGroups::CategoriseSchools.new(schools: @schools).school_categories(@advice_page)
        alert_type = AlertType.find_by_class_name('AlertElectricityBaseloadVersusBenchmark')
        @baseload_alerts = SchoolGroups::Alerts.new(@schools).alerts(alert_type) if alert_type

        @baseload_per_pupil_headers = Comparison::BaseloadPerPupil.report_headers
      end

      private

      def run_report
        @baseload_per_pupil_report = Comparison::Report.find_by!(key: :baseload_per_pupil)
        @results = load_data
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

      def index_params
        { benchmark: :baseload_per_pupil, school_group_ids: [@school_group.id] }
      end

      def load_data
        Comparison::BaseloadPerPupil.for_schools(@schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
      end
    end
  end
end
