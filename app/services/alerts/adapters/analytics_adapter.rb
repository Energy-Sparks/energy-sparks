module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.valid_alert? ? produce_report(analysis_object) : invalid_alert_report(analysis_object)
      end

    private

      def produce_report(analysis_object)
        analysis_object.analyse(@analysis_date)

        variables = if analysis_object.make_available_to_users?
                      {
                        template_data: analysis_object.front_end_template_data,
                        chart_data:    analysis_object.front_end_template_chart_data,
                        table_data:    analysis_object.front_end_template_table_data,
                        priority_data: analysis_object.priority_template_data,
                        benchmark_data: (alert_class.benchmark_template_variables.empty? ? {} : analysis_object.benchmark_template_data)
                      }
                    else
                      {}
                    end

        Report.new({
          valid:       true,
          rating:      analysis_object.rating,
          enough_data: analysis_object.enough_data,
          relevance:   analysis_object.relevance
        }.merge(variables))
      end

      def invalid_alert_report(analysis_object)
        Report.new(
          valid:       false,
          rating:      nil,
          enough_data: nil,
          relevance:   analysis_object.relevance
        )
      end
    end
  end
end
