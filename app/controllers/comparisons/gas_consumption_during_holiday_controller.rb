module Comparisons
  class GasConsumptionDuringHolidayController < BaseController
    include ConsumptionDuringHoliday

    private

    def key
      :gas_consumption_during_holiday
    end

    def model
      Comparison::GasConsumptionDuringHoliday
    end
  end
end
