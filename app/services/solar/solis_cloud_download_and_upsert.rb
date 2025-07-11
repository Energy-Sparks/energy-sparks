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

    def time_to_index(time)
      split = time.split(':')
      index = split[0].to_i * 2
      index += 1 if split[1].to_i > 30
      index
    end

    TO_HOUR = 5 / 60.0

    def create_kwh_data_x48(data)
      x48 = Array.new(48, 0.0)
      data.each do |entry|
        x48[time_to_index(entry['timeStr'])] += (entry['power'] / 1000.0) * TO_HOUR
      end
      x48
    end

    def start_date(date_string: nil, meter: nil)
      if @requested_start_date
        @requested_start_date
      else
        latest_reading = meter&.amr_data_feed_readings&.maximum(:reading_date)
        if latest_reading
          Date.parse(latest_reading) - 5.days
        elsif date_string
          Date.parse(date_string)
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

    def zero_leftover(array)
      # first entries can sometimes carry over total from previous day, reset those to zero
      index = array.find_index { |_time, total| total < 1 }
      array.each_with_index { |_, i| array[i][1] = 0 if i < index } unless index.nil?
      array
    end

    def remove_ending_nils(array)
      array[0..(array.rindex { |v| !v.nil? } || 47)]
    end

    def fill_missing(array)
      return [] if array.empty?

      previous = 0
      (0..47).map { |i| format('%<hour>02d:%<min>02d', hour: i / 2, min: (i % 2) * 30) }
             .index_with(nil)
             .merge(array.to_h)
             .values
             # remove trailing nils
             .then { |array| array[0..(array.rindex { |v| !v.nil? } || 47)] }
             # replace remaining nils
             .map { |value| value.nil? ? previous : previous = value }
    end

    def calculate_differences(array)
      return [] if array.empty?

      [array[0]] + array.each_cons(2).map { |previous, current| current - previous }
    end

    def convert_invertor_day(data)
      data.pluck('timeStr', 'eToday')
          .map { |time, total| [Time.parse(time).utc, total] }
          .then { |array| zero_leftover(array) }
          .group_by { |time, _| nearest_half_hour(time) }
          .map { |boundary, group| [boundary.strftime('%H:%M'), group.min_by { |time, _| (boundary - time).abs }[1]] }
          .then { |half_hourly| fill_missing(half_hourly[0..47]) }
          .then { |half_hourly| calculate_differences(half_hourly) }
          .then { |half_hourly| half_hourly.fill(nil, half_hourly.length..47) }
    end
  end
end
