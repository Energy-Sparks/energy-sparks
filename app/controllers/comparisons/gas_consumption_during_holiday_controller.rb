module Comparisons
  class GasConsumptionDuringHolidayController < Shared::ConsumptionDuringHoliday
    private

    def key
      :gas_consumption_during_holiday
    end

    def model
      Comparison::GasConsumptionDuringHoliday
    end
  end
end
