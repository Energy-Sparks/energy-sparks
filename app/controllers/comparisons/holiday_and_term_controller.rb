# frozen_string_literal: true

module Comparisons
  class HolidayAndTermController < Shared::ArbitraryPeriodController
    private

    def set_headers(include_previous_period_unadjusted: true)
      super(include_previous_period_unadjusted: include_previous_period_unadjusted, holiday_name: true)
    end

    def render_csv_row(result, table_name)
      row = super
      if table_name != :total
        row.insert(2, holiday_name(result_table_name_value(result, table_name, :current_period, :type),
                                   result_table_name_value(result, table_name, :current_period, :start_date),
                                   result_table_name_value(result, table_name, :current_period, :end_date),
                                   partial: result_table_name_value(result, table_name, :truncated, :current_period)))
      end
      row
    end

    def key
      :holiday_and_term
    end

    def load_data
      Comparison::HolidayAndTerm.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end
  end
end
