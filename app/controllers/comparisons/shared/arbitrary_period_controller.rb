# frozen_string_literal: true

module Comparisons
  module Shared
    class ArbitraryPeriodController < BaseController
      include MultipleTableComparison
      include ComparisonsHelper
      include AdvicePageHelper

      private

      def set_headers(include_previous_period_unadjusted: true, holiday_name: false, urn: false)
        @urn = urn
        super()
        @include_previous_period_unadjusted = include_previous_period_unadjusted
        electricity_groups = header_groups(fuel: false, holiday_name:)
        @electricity_colgroups = colgroups(groups: electricity_groups)
        @electricity_headers = headers(groups: electricity_groups)
        heating_groups = header_groups(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted,
                                       holiday_name:)
        @heating_colgroups = colgroups(groups: heating_groups)
        @heating_headers = headers(groups: heating_groups)
        @period_type_string = I18n.t('comparisons.period_types.periods')
      end

      def header_groups(fuel: true, previous_period_unadjusted: false, holiday_name: false)
        [
          { label: '',
            headers: [
              t('analytics.benchmarking.configuration.column_headings.school'),
              request.format.csv? && @urn && t('onboarding.completion.new.school_details_section.urn'),
              fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
              t('activerecord.attributes.school.activation_date'),
              holiday_name && t('analytics.benchmarking.configuration.column_headings.most_recent_holiday')
            ] },
          kwh_headers(previous_period_unadjusted),
          kg_headers,
          gbp_headers
        ]
      end

      def kwh_headers(previous_period_unadjusted)
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
          headers: [previous_period_unadjusted && t('comparisons.column_headings.previous_period_unadjusted'),
                    t('comparisons.column_headings.previous_period'),
                    t('comparisons.column_headings.current_period'),
                    t('analytics.benchmarking.configuration.column_headings.change_pct')] }
      end

      def kg_headers
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'),
          headers: [t('comparisons.column_headings.previous_period'),
                    t('comparisons.column_headings.current_period'),
                    t('analytics.benchmarking.configuration.column_headings.change_pct')] }
      end

      def gbp_headers
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'),
          headers: [t('comparisons.column_headings.previous_period'),
                    t('comparisons.column_headings.current_period'),
                    t('analytics.benchmarking.configuration.column_headings.change_pct')] }
      end

      def table_configuration
        {
          total: I18n.t('comparisons.tables.total_usage'),
          electricity: I18n.t('comparisons.tables.electricity_usage'),
          gas: I18n.t('comparisons.tables.gas_usage'),
          storage_heater: I18n.t('comparisons.tables.storage_heater_usage')
        }
      end

      def create_charts(_results)
        create_single_number_chart(@results, :total_percentage_change_kwh, 100.0, :change_kwh, :percent)
      end

      def render_csv
        table_name = filter[:table_name].to_sym
        csv = CSV.generate do |csv|
          colgroups, headers = case table_name
                               when :gas, :storage_heater
                                 [@heating_colgroups, @heating_headers]
                               when :electricity
                                 [@electricity_colgroups, @electricity_headers]
                               when :total
                                 [@colgroups, @headers]
                               else
                                 raise "unknown table_name #{fuel_type}"
                               end
          csv << csv_colgroups(colgroups)
          csv << headers
          @results.each do |result|
            next if result_table_name_value(result, table_name, :current_period, :kwh).blank?

            csv << render_csv_row(result, table_name)
          end
        end
        render plain: csv
      end

      def render_csv_row(result, table_name)
        [result.school.name,
         render_csv_urn(result),
         table_name == :total ? result.fuel_type_names : nil,
         result.activation_date.iso8601,
         if @include_previous_period_unadjusted && %i[gas storage_heater].include?(table_name)
           format_unit(result_table_name_value(result, table_name, :previous_period, :kwh_unadjusted), Float)
         end,
         *render_csv_block(result, table_name, :kwh),
         *render_csv_block(result, table_name, :co2),
         *render_csv_block(result, table_name, :gbp)].compact
      end

      def render_csv_block(result, table_name, type)
        [format_unit(result_table_name_value(result, table_name, :previous_period, type), Float),
         format_unit(result_table_name_value(result, table_name, :current_period, type), Float),
         format_csv_percent_change(result_table_name_value(result, table_name, :previous_period, type),
                                   result_table_name_value(result, table_name, :current_period, type))]
      end

      def result_table_name_value(result, table_name, period, unit)
        if table_name == :total
          result.public_send("total_#{period}", unit:)
        else
          result.public_send("#{table_name}_#{period}_#{unit}")
        end
      end

      def render_csv_urn(result)
        return unless @urn

        result.school.full_school ? result.school.urn : ''
      end
    end
  end
end
