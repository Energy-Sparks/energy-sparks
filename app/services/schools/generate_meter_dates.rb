require 'dashboard'

module Schools
  class GenerateMeterDates
    def initialize(meter_collection)
      @meter_collection = meter_collection
    end

    def generate
      dates = {}
      add_dates_for_fuel_type(dates, :electricity) if @meter_collection.electricity?
      add_dates_for_fuel_type(dates, :gas) if @meter_collection.gas?
      add_dates_for_fuel_type(dates, :storage_heater) if @meter_collection.storage_heaters?
      dates
    end

    private

    def add_dates_for_fuel_type(dates, fuel_type)
      aggregate_meter = @meter_collection.aggregate_meter(fuel_type)
      if aggregate_meter
        dates[fuel_type] = {
          start_date: aggregate_meter.amr_data.start_date.iso8601,
          end_date: aggregate_meter.amr_data.end_date.iso8601
        }
      end
    end
  end
end
