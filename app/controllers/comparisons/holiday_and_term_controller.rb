module Comparisons
  class HolidayAndTermController < Shared::ArbitraryPeriodController
    private

    def set_headers(include_previous_period_unadjusted: true)
      super(include_previous_period_unadjusted: include_previous_period_unadjusted, holiday_name: true)
    end

    def key
      :holiday_and_term
    end

    def load_data
      Comparison::HolidayAndTerm.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end
  end
end
