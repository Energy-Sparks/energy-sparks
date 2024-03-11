module Comparisons
  class ChangeInGasHolidayConsumptionPreviousYearsHolidayController < BaseController
    include ChangeInConsumption

    private

    def key
      :change_in_gas_holiday_consumption_previous_years_holiday
    end

    def model
      Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday
    end
  end
end
