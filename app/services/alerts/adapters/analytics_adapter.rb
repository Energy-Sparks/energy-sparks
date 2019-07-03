module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.valid_alert? ? produce_report(analysis_object) : invalid_alert_report
      end

    private

      def produce_report(analysis_object)
        analysis_object.analyse(@analysis_date)

        variables = if pull_variable_data?(analysis_object)
                      {
                        template_data: analysis_object.front_end_template_data,
                        chart_data:    analysis_object.front_end_template_chart_data,
                        table_data:    analysis_object.front_end_template_table_data
                      }
                    else
                      {}
                    end

        Report.new({
          valid:       true,
          status:      analysis_object.status,
          rating:      analysis_object.rating,
          enough_data: analysis_object.enough_data
        }.merge(variables))
      end

      def pull_variable_data?(analysis_object)
        ![nil, :failed].include?(analysis_object.status) && (analysis_object.enough_data == :enough)
      end

      def invalid_alert_report
        Report.new(
          valid:       false,
          status:      nil,
          rating:      nil,
          enough_data: nil
        )
      end
    end
  end
end
