# frozen_string_literal: true

module Comparisons
  class ElectricityConsumptionDuringHolidayController < BaseController
    include ConsumptionDuringHoliday

    private

    def key
      :electricity_consumption_during_holiday
    end

    def model
      Comparison::ElectricityConsumptionDuringHoliday
    end
  end
end
