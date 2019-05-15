module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report
        analysis_obj = alert_class.new(@aggregate_school)
        analysis_report = generate_report(analysis_obj)

        variables = if pull_variable_data?(analysis_report)
                      {
                        template_data: analysis_obj.front_end_template_data,
                        chart_data:    analysis_obj.front_end_template_chart_data,
                        table_data:    analysis_obj.front_end_template_table_data
                      }
                    else
                      {}
                    end

        Report.new({
          status:   analysis_report.status,
          summary:  summary(analysis_report),
          detail:   analysis_report.detail,
          help_url: analysis_report.help_url,
          rating:   analysis_report.rating,
        }.merge(variables))
      end

    private

      def generate_report(analysis_obj)
        analysis_obj.analyse(@analysis_date)
        analysis_obj.analysis_report
      end

      def pull_variable_data?(analysis_report)
        !(analysis_report.status == :failed) && @alert_type.has_variables?
      end

      def summary(analysis_report)
        analysis_report.summary || "There was a problem running the #{@alert_type.title} alert. This is likely due to missing data."
      end
    end
  end
end
