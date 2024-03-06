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

    # def create_charts(results)
    #   create_single_number_chart(results, :current_year_percent_of_target_relative, :percent_above_or_below_target_since_target_set, :percent)
    # end
  end
end
