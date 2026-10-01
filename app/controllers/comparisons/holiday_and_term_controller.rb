# frozen_string_literal: true

module Comparisons
  class HolidayAndTermController < Shared::ArbitraryPeriodController
    private

    def set_headers(include_previous_period_unadjusted: true)
      super(include_previous_period_unadjusted: include_previous_period_unadjusted, holiday_name: true)
    end

    def render_csv_row(result, table_name)
      row = super
      row.insert(2, result_holiday_name(result, table_name)) if table_name != :total
      row
    end

    def key
      :holiday_and_term
    end

    def load_data
      Comparison::HolidayAndTerm.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end

    def result_holiday_name(result, table_name)
      holiday_name(result_value(result, table_name, :current_period, :type),
                   result_value(result, table_name, :current_period, :start_date),
                   result_value(result, table_name, :current_period, :end_date),
                   partial: result_value(result, table_name, :truncated, :current_period))
    end
    helper_method :result_holiday_name
  end
end
