module Comparisons
  class GasConsumptionDuringHolidayController < Shared::ConsumptionDuringHolidayController
    private

    def key
      :gas_consumption_during_holiday
    end

    def model
      Comparison::GasConsumptionDuringHoliday
    end
  end
end
