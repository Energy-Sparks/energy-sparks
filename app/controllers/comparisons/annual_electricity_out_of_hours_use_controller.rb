module Comparisons
  class AnnualElectricityOutOfHoursUseController < BaseController
    private

    def key
      :annual_electricity_out_of_hours_use
    end

    def advice_page_key
      :electricity_out_of_hours
    end

    def load_data
      Comparison::AnnualElectricityOutOfHoursUse.where(school: @schools).where.not(schoolday_open_percent: nil).order(schoolday_open_percent: :desc)
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
