# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousYearsHolidayController < Shared::ChangeInConsumptionController
    private

    def key
      :change_in_electricity_holiday_consumption_previous_years_holiday
    end

    def model
      Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
    end
  end
end
