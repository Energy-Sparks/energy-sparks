# frozen_string_literal: true

module Usage
  class AnnualUsageBreakdownService
    include AnalysableMixin
    def initialize(meter_collection:, fuel_type: :electricity)
      raise 'Invalid fuel type' unless %i[electricity gas storage_heater].include? fuel_type

      @fuel_type = fuel_type
      @meter_collection = meter_collection
      @delegate = UsageBreakdownService.new(meter_collection: meter_collection, fuel_type: fuel_type)
    end

    def annual_out_of_hours_kwh
      usage = @delegate.out_of_hours_kwh
      { out_of_hours: usage[:out_of_hours], total_annual: usage[:total] }
    end

    # Calculates a breakdown of the annual usage over the last twelve months
    # Broken down by usage during school day open, closed, weekends and holidays
    #
    # @return [Usage::UsageCategoryBreakdown] the calculated breakdown
    def usage_breakdown
      raise 'Not enough data: at least one years worth of meter data is required' unless enough_data?

      @delegate.usage_breakdown
    end

    def enough_data?
      meter_date_range_checker.one_years_data?
    end

    def data_available_from
      meter_date_range_checker.date_when_one_years_data
    end

    private

    def aggregate_meter
      @aggregate_meter ||= case @fuel_type
                           when :electricity then @meter_collection.aggregated_electricity_meters
                           when :gas then @meter_collection.aggregated_heat_meters
                           when :storage_heater then @meter_collection.storage_heater_meter
                           end
    end

    def meter_date_range_checker
      @meter_date_range_checker ||= ::Util::MeterDateRangeChecker.new(aggregate_meter, Date.today)
    end
  end
end
