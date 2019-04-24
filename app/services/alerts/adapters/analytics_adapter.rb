module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report
        analysis_obj = alert_class.new(@aggregate_school)
        analysis_obj.analyse(@analysis_date)

        analysis_report = analysis_obj.analysis_report
        summary = analysis_report.summary || "There was a problem running the #{@alert_type.title} alert. This is likely due to missing data."
        pull_template_data = !(analysis_report.status == :failed) && @alert_type.has_variables?

        Report.new(
          status:   analysis_report.status,
          summary:  summary,
          detail:   analysis_report.detail,
          help_url: analysis_report.help_url,
          rating:   analysis_report.rating,
          template_data: pull_template_data ? analysis_obj.front_end_template_data : {},
          chart_data:    pull_template_data ? analysis_obj.front_end_template_charts : {},
          table_data:    pull_template_data ? analysis_obj.front_end_template_tables : {}
        )
      end
    end
  end
end
