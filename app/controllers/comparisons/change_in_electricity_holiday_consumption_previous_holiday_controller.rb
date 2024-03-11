# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousHolidayController <
      ChangeInElectricityHolidayConsumptionPreviousYearsHolidayController
    private

    def key
      :change_in_electricity_holiday_consumption_previous_holiday
    end

    def load_data
      Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday
        .where(school: @schools).where.not(difference_percent: nil).order(difference_percent: :desc)
    end
  end
end
