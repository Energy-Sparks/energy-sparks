# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousHolidayController < Shared::ChangeInConsumptionController
    private

    def key
      :change_in_electricity_holiday_consumption_previous_holiday
    end

    def model
      Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday
    end
  end
end
