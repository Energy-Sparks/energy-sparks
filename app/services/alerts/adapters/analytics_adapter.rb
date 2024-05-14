# frozen_string_literal: true

require 'dashboard'

module Alerts
  module Adapters
    class AnalyticsAdapter < Adapter
      def report(alert_configuration: nil)
        analysis_object = alert_class.new(@aggregate_school)
        if analysis_object.respond_to?(:comparison_configuration=)
          analysis_object.comparison_configuration = alert_configuration
        end
        if analysis_object.valid_alert?
          benchmark = benchmark_variables?(alert_class)
          analysis_object.analyse(*[@analysis_date,
                                    benchmark ? @use_max_meter_date_if_less_than_asof_date : nil].compact)
          produce_report(analysis_object, benchmark)
        else
          invalid_alert_report(analysis_object)
        end
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
        Report.new(valid: true,
                   rating: analysis_object.rating,
                   enough_data: analysis_object.enough_data,
                   relevance: analysis_object.relevance, **variable_data(analysis_object, benchmark))
      end

      def variable_data(analysis_object, benchmark)
        return {} unless analysis_object.make_available_to_users?

        variable_data = {
          template_data: analysis_object.front_end_template_data,
          chart_data: analysis_object.front_end_template_chart_data,
          table_data: analysis_object.front_end_template_table_data,
          priority_data: analysis_object.priority_template_data,
          variables: rename_variables(convert_for_storage(analysis_object.variables_for_reporting)),
        }

        if defined? analysis_object.reporting_period
          variable_data[:reporting_period] = analysis_object.reporting_period
        end

        I18n.with_locale(:cy) do
          variable_data[:template_data_cy] = analysis_object.front_end_template_data
        end

        if benchmark
          variable_data[:benchmark_data] = analysis_object.benchmark_template_data
          I18n.with_locale(:cy) do
            variable_data[:benchmark_data_cy] = analysis_object.benchmark_template_data
          end
        end

        variable_data
      end

      def invalid_alert_report(analysis_object)
        Report.new(
          valid: false,
          rating: nil,
          enough_data: nil,
          relevance: analysis_object.relevance
        )
      end

      # Rename variables that include "£"" as the encoding can cause issues, e.g. in the rails dbconsole
      def rename_variables(variables)
        variables.deep_transform_keys do |key|
          :"#{key.to_s.gsub('£', 'gbp')}"
        end
      end

      def convert_for_storage(variables)
        variables.transform_values { |v| convert(v) }
      end

      # Converts variables with specific types of values for storing
      # in Postgres. Floating point and boolean values are converted to
      # strings that Postgres can cast back into the appropriate type
      def convert(val)
        return val if val.nil? || !needs_conversion?(val)

        if [true, false].include? val
          val.to_s
        elsif val.infinite? == 1
          'Infinity'
        elsif val.infinite? == -1
          '-Infinity'
        elsif val.nan?
          'NaN'
        else
          val
        end
      end

      def needs_conversion?(val)
        val.is_a?(Float) || val.is_a?(BigDecimal) || [true, false].include?(val)
      end
    end
  end
end
