# frozen_string_literal: true

require 'dashboard'

module Amr
  class AnalyticsValidatedMeterCollectionFactory < AnalyticsUnvalidatedMeterCollectionFactory
    private

    def heat_meters
      @active_record_school.meters_with_validated_readings(:gas)
    end

    def electricity_meters
      @active_record_school.meters_with_validated_readings(:electricity)
    end

    def any_meters_with_readings?
      @active_record_school.meters_with_validated_readings.any?
    end

    def add_amr_data(active_record_meter)
      dashboard_meter = Amr::AnalyticsMeterFactory.new(active_record_meter, @meter_collection).build

      validated_reading_array = AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).pluck(:reading_date, :status, :substitute_date, :upload_datetime, :kwh_data_x48)
      validated_reading_array.each do |reading|
        dashboard_meter.amr_data.add(reading[0], OneDayAMRReading.new(active_record_meter.id, reading[0], reading[1], reading[2], reading[3], reading[4].map(&:to_f)))
      end

      dashboard_meter
    end
  end
end
