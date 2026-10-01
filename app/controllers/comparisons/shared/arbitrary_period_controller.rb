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
        @colgroups = { total: @colgroups }
        @headers = { total: @headers }
        @include_previous_period_unadjusted = include_previous_period_unadjusted

        set_table_headers([:electricity], fuel: false, holiday_name:)
        set_table_headers(%i[gas storage_heater], fuel: false,
                                                  previous_period_unadjusted: @include_previous_period_unadjusted,
                                                  holiday_name:)
      end

      def set_table_headers(table_names, **)
        groups = header_groups(**)
        table_names.each do |table_name|
          @colgroups[table_name] = colgroups(groups:)
          @headers[table_name] = headers(groups:)
        end
      end

      def header_groups(fuel: true, previous_period_unadjusted: false, holiday_name: false)
        [{ label: '',
           headers: [
             t('analytics.benchmarking.configuration.column_headings.school'),
             request.format.csv? && @urn && t('onboarding.completion.new.school_details_section.urn'),
             fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
             t('activerecord.attributes.school.activation_date'),
             holiday_name && t('analytics.benchmarking.configuration.column_headings.most_recent_holiday')
           ] },
         { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
           headers: section_headers(previous_period_unadjusted) },
         { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), headers: section_headers(false) },
         { label: t('analytics.benchmarking.configuration.column_groups.gbp'), headers: section_headers(false) }]
      end

      def section_headers(previous_period_unadjusted)
        [previous_period_unadjusted && t('comparisons.column_headings.previous_period_unadjusted'),
         t('comparisons.column_headings.previous_period'),
         t('comparisons.column_headings.current_period'),
         t('analytics.benchmarking.configuration.column_headings.change_pct')]
      end

      def table_configuration
        { total: I18n.t('comparisons.tables.total_usage'),
          electricity: I18n.t('comparisons.tables.electricity_usage'),
          gas: I18n.t('comparisons.tables.gas_usage'),
          storage_heater: I18n.t('comparisons.tables.storage_heater_usage') }
      end

      def create_charts(_results)
        create_single_number_chart(@results, :total_percentage_change_kwh, 100.0, :change_kwh, :percent)
      end

      def render_csv
        table_name = filter[:table_name].to_sym
        csv = CSV.generate do |csv|
          csv << csv_colgroups(@colgroups[table_name])
          csv << @headers[table_name]
          @results.each do |result|
            next if result_value(result, table_name, :current_period, :kwh).blank?

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
           format_unit(result_value(result, table_name, :previous_period, :kwh_unadjusted), Float)
         end,
         *%i[kwh co2 gbp].flat_map { |unit| render_csv_block(result, table_name, unit) }].compact
      end

      def render_csv_block(result, table_name, type)
        [format_unit(result_value(result, table_name, :previous_period, type), Float),
         format_unit(result_value(result, table_name, :current_period, type), Float),
         format_csv_percent_change(result_value(result, table_name, :previous_period, type),
                                   result_value(result, table_name, :current_period, type))]
      end

      def result_value(result, table_name, period, unit)
        unit = :gbp if unit == :£
        if period == :percentage_change && table_name != :total
          percent_change(result_value(result, table_name, :previous_period, unit),
                         result_value(result, table_name, :current_period, unit))
        else
          unit_suffix, kwargs = if table_name == :total
                                  [nil, { unit: }]
                                else
                                  [unit.nil? ? nil : "_#{unit}", {}]
                                end
          result.public_send("#{table_name}_#{period}#{unit_suffix}", **kwargs)
        end
      end
      helper_method :result_value

      def render_csv_urn(result)
        return unless @urn

        result.school.full_school ? result.school.urn : ''
      end
    end
  end
end
