# frozen_string_literal: true

module Solar
  class MeterZDownloadAndUpsert < BaseDownloadAndUpsert
    def download_and_upsert
      readings = download
      MeterZUpserter.new(installation: @installation, readings:, import_log:).perform
    end

    private

    def school = nil

    def job = :meter_z_download

    def start_date(date_string: nil, meter: nil)
      if @requested_start_date
        @requested_start_date
      else
        latest_reading = meter&.amr_data_feed_readings&.maximum(:reading_date)
        if latest_reading
          Time.zone.parse(latest_reading).to_date - 5.days
        elsif date_string
          Time.zone.parse(date_string).to_date
        else
          nil
        end
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

    # def convert_to_readings_by_day(readings)
    #   readings.each_with_object(Hash.new { |h, k| h[k] = Array.new(48) }) do |reading, readings_by_day|
    #     datetime = DateTime.parse(reading['reading_timestamp'])
    #     day = datetime.to_date
    #     index = hh_index(datetime)
    #     accumulated = reading.dig('readings', 'accumulated_kilowatt_hours').to_f

    #     day_readings = readings_by_day[day]
    #     day_readings[index] = accumulated

    #     readings_by_day[day.prev_day][48] = accumulated if index.zero?
    #   end
    # end

    def convert_from_accumulated(readings_by_day)
      readings_by_day.filter_map do |date, readings|
        next if readings.any?(&:nil?)

        [date, readings.each_cons(2).map { |a, b| b - a }]
      end
    end

    def hh_index(time)
      total_minutes = (time.hour * 60) + time.min
      total_minutes / 30
    end

    def convert_invertor_day(data)
      readings = data.pluck('timeStr', 'pac').to_h.transform_keys { |time| Time.zone.parse(time).utc }
      return Array.new(48, nil) if readings.length < 10

      nearest_neighbours =
        readings.group_by { |time, _| nearest_half_hour(time) }
                .to_h { |boundary, group| [boundary, group.min_by { |time, _| (boundary - time).abs }[1]] }
      merged = nearest_neighbours.merge(readings)
      indexed_readings = Array.new(48) { [] }
      minute_boundary = [0, 30]
      merged.each do |time, power|
        total_minutes = (time.hour * 60) + time.min
        index = total_minutes / 30
        indexed_readings[index] << [time, power]
        indexed_readings[index - 1] << [time, power] if minute_boundary.include?(time.min) && time.sec == 0
      end
      indexed_readings.map do |group|
        group.sort_by(&:first).each_cons(2).sum do |(a_time, a_power), (b_time, b_power)|
          ((a_power + b_power) / (2 * 1000.0)) * ((b_time - a_time) / 3600.0)
        end
      end
    end
  end
end
