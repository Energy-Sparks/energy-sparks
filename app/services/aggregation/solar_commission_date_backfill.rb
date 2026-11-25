# frozen_string_literal: true

module Aggregation
  module SolarCommissionDateBackfill
    def self.process(pv_meter_map, solar_pv_mpan_meter_mappings)
      pv_meter_map.meters.each do |meter|
        commissioned_date = solar_pv_mpan_meter_mappings.dig(meter, :commissioned_date)
        backfill_meter_to_commissioned_date(meter, commissioned_date) if commissioned_date
      end
    end

    private_class_method def self.backfill_meter_to_commissioned_date(meter, commissioned_date)
      amr_data = meter.amr_data
      return if commissioned_date.nil? || amr_data.start_date <= commissioned_date

      start_date = amr_data.start_date
      days_to_copy = (start_date - commissioned_date).to_i
      initial_solar_readings(meter, days_to_copy).each_with_index do |reading, index|
        date = commissioned_date + index
        amr_data.add(date, OneDayAMRReading.new(date, 'SOLC', reading.date, DateTime.now, reading.kwh_data_x48.dup))
      end
    end

    private_class_method def self.initial_solar_readings(meter, days_to_copy)
      start_date = meter.amr_data.start_date
      readings = (start_date...(start_date + days_to_copy)).map { |date| meter.amr_data[date] }
      if readings.any?(&:nil?)
        Rails.logger.warn "Skipping commissioned-date backfill for meter #{meter.mpan_mprn}: #{days_to_copy} " \
                          "consecutive days required from #{start_date}, but not enough readings available"
        return []
      end
      readings
    end
  end
end
