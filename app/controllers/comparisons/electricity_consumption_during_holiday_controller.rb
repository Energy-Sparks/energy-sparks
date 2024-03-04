# frozen_string_literal: true

module Comparisons
  class ElectricityConsumptionDuringHolidayController < BaseController
    private

    def key
      :electricity_consumption_during_holiday
    end

    def load_data
      Comparison::ElectricityConsumptionDuringHoliday.where(school: @schools)
                                                     .where.not(holiday_projected_usage_gbp: nil)
                                                     .order(holiday_projected_usage_gbp: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :holiday_projected_usage_gbp, nil, 'projected_usage_by_end_of_holiday', '£')
    end
  end
end
