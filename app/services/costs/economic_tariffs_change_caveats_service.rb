# frozen_string_literal: true

module Costs
  class EconomicTariffsChangeCaveatsService
    def initialize(meter_collection:, fuel_type:)
      @meter_collection = meter_collection
      @fuel_type = fuel_type
    end

    def calculate_economic_tariff_changed
      return nil if meter.nil?
      return nil if changed_dates.empty?
      return nil if last_change_date >= end_date

      OpenStruct.new(
        last_change_date: last_change_date,
        rate_before_£_per_kwh: before,
        rate_after_£_per_kwh: after,
        percent_change: (after - before) / before
      )
    end

    private

    def before
      @before ||= meter.amr_data.blended_£_per_kwh_date_range(start_date, last_change_date - 1)
    end

    def after
      @after ||= meter.amr_data.blended_£_per_kwh_date_range(last_change_date, end_date)
    end

    def last_change_date
      @last_change_date ||= changed_dates.last
    end

    def changed_dates
      @changed_dates ||= meter.meter_tariffs.tariff_change_dates_in_period(start_date, end_date)
    end

    def start_date
      @start_date ||= [meter.amr_data.end_date - 365, meter.amr_data.start_date].max
    end

    def end_date
      @end_date ||= meter.amr_data.end_date
    end

    def meter
      @meter ||= @meter_collection.aggregate_meter(@fuel_type)
    end
  end
end
