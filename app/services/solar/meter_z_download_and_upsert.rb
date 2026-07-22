# frozen_string_literal: true

module Solar
  class MeterZDownloadAndUpsert < BaseDownloadAndUpsert
    private

    def download_and_upsert
      readings = download
      MeterZUpserter.new(installation: @installation, readings:, import_log:).perform
    end

    def school = nil

    def job = :meter_z_download

    def start_date(meter: nil)
      if @requested_start_date
        @requested_start_date
      else
        latest_reading = meter&.amr_data_feed_readings&.maximum(:reading_date)
        Time.zone.parse(latest_reading).to_date - 5.days if latest_reading
      end
    end

    def download
      @installation.meters.map do |meter|
        readings = @installation.readings(meter.meter_serial_number, start_date(meter:))
        [:solar_pv, { meter_id: meter.meter_serial_number, readings: convert_readings(readings) }]
      end
    end

    def convert_readings(readings)
      readings_by_day = convert_to_readings_by_day(readings)
      convert_from_accumulated(readings_by_day)
    end

    def convert_to_readings_by_day(readings)
      readings_by_day = Hash.new { |hash, key| hash[key] = Array.new(48, nil) }
      readings.each do |reading|
        date, accumulated, index = parse_reading(reading)
        readings_by_day[date][index] = accumulated
        readings_by_day[date.prev_day][48] = accumulated if index.zero?
      end
      readings_by_day
    end

    def parse_reading(reading)
      datetime = DateTime.parse(reading['reading_timestamp'])
      accumulated = reading['readings']['accumulated_kilowatt_hours'].to_f
      [datetime.to_date, accumulated, hh_index(datetime)]
    end

    def convert_from_accumulated(readings_by_day)
      readings_by_day.filter_map do |date, readings|
        next if readings.any?(&:nil?)

        [date, readings.each_cons(2).map { |a, b| b - a }]
      end
    end
  end
end
