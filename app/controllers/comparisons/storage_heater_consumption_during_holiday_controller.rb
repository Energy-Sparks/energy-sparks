# frozen_string_literal: true

module Comparisons
  class StorageHeaterConsumptionDuringHolidayController < BaseController
    include ConsumptionDuringHoliday

    private

    def key
      :storage_heater_consumption_during_holiday
    end

    def model
      Comparison::StorageHeaterConsumptionDuringHoliday
    end
  end
end
