module Comparisons
  class ChangeInGasHolidayConsumptionPreviousHolidayController < Shared::ChangeInConsumption
    private

    def key
      :change_in_gas_holiday_consumption_previous_holiday
    end

    def model
      Comparison::ChangeInGasHolidayConsumptionPreviousHoliday
    end
  end
end
