require 'dashboard'

module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.valid_alert? ? produce_report(analysis_object, benchmark_variables?(alert_class)) : invalid_alert_report(analysis_object)
      end

      def content(user_type = nil)
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.analyse(@analysis_date)
        # TODO: error, data, validity handling
        analysis_object.front_end_content(user_type: user_type)
      end

      def benchmark_dates
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.benchmark_dates(@analysis_date)
      end

      def has_structured_content?
        analysis_object = alert_class.new(@aggregate_school)
        analysis_object.has_structured_content?
      end

      def structured_content
        analysis_object = alert_class.new(@aggregate_school)
        has_structured_content? ? analysis_object.structured_content : []
      end

    private

      def benchmark_variables?(alert_class)
        alert_class.benchmark_template_variables.present? && @alert_type.analytics?
      end

      def produce_report(analysis_object, benchmark)
        benchmark ? analysis_object.analyse(@analysis_date, @use_max_meter_date_if_less_than_asof_date) : analysis_object.analyse(@analysis_date)
        variables = variable_data(analysis_object, benchmark)

        Report.new({
          valid:       true,
          rating:      analysis_object.rating,
          enough_data: analysis_object.enough_data,
          relevance:   analysis_object.relevance
        }.merge(variables))
      end

      def variable_data(analysis_object, benchmark)
        return {} unless analysis_object.make_available_to_users?

        variable_data = {
          template_data: analysis_object.front_end_template_data,
          chart_data:    analysis_object.front_end_template_chart_data,
          table_data:    analysis_object.front_end_template_table_data,
          priority_data: analysis_object.priority_template_data,
        }

        variable_data[:benchmark_data] = analysis_object.benchmark_template_data if benchmark
        variable_data
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
