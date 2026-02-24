# frozen_string_literal: true

module Solar
  class SolisCloudDownloadAndUpsert < BaseDownloadAndUpsert
    def download_and_upsert
      readings = download
      SolisCloudUpserter.new(installation: @installation, readings:, import_log:).perform
    end

    private

    def school
      nil
    end

    def job
      :solis_cloud_download
    end

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
          1.year.ago.to_date
        end
      end
    end

    def download
      api = @installation.api
      @installation.meters.map do |meter|
        detail = @installation.inverter_detail_list.find { |inverter| inverter['sn'] == meter.meter_serial_number }
        readings = (start_date(date_string: detail&.[]('fisGenerateTimeStr'), meter:)..end_date).filter_map do |date|
          Rails.logger.debug { "SolisCloud download for #{meter.meter_serial_number} #{date}" }
          begin
            day = api.inverter_day(meter.meter_serial_number, date)
            [date, convert_invertor_day(day['data'])] if day['data']
          rescue StandardError => e
            e.rollbar_context = { solis_cloud_inverter_id: meter.meter_serial_number, date:, day: }
            raise
          end
        end
        [:solar_pv, { serial_number: meter.meter_serial_number, readings: }]
      end
    end

    def nearest_half_hour(time)
      time.dup.change(hour: time.hour + (time.min >= 45 ? 1 : 0), min: time.min >= 15 && time.min < 45 ? 30 : 0)
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
        total_minutes = time.hour * 60 + time.min
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
