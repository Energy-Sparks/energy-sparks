module Comparisons
  class AnnualGasOutOfHoursUseController < BaseController
    private

    def headers
      Comparison::AnnualGasOutOfHoursUse.default_headers
    end

    def key
      :annual_gas_out_of_hours_use
    end

    def advice_page_key
      :gas_out_of_hours
    end

    def load_data
      Comparison::AnnualGasOutOfHoursUse.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        schoolday_open_percent: :school_day_open,
        schoolday_closed_percent: :school_day_closed,
        holidays_percent: :holiday,
        weekends_percent: :weekend,
        community_percent: :community
        }, 100.0, :percent)
    end
  end
end
