# frozen_string_literal: true

module Solar
  class SolisCloudDownloadAndUpsert < BaseDownloadAndUpsert
    def download_and_upsert
      readings = download
      SolisCloudUpserter.new(installation: @installation, readings:, import_log:).perform
    end

    private

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

    def start_date(date_string = nil)
      if @requested_start_date
        @requested_start_date
      elsif latest_reading
        latest_reading - 5.days
      elsif date_string
        Date.parse(date_string)
      else
        1.year.ago
      end
    end

    def download
      api = DataFeeds::SolisCloudApi.new(@installation.api_id, @installation.api_secret)
      @installation.meters.map do |meter|
        detail = @installation.inverter_detail_list.find { |inverter| inverter['sn'] == meter.meter_serial_number }
        readings = (start_date(detail&.[]('fisGenerateTimeStr'))..end_date).filter_map do |date|
          Rails.logger.debug { "SolisCloud download for #{meter.meter_serial_number} #{date}" }
          begin
            day = api.inverter_day(meter.meter_serial_number, date)
            # sometimes the data attribute can be nil
            [date, convert_invertor_day(day['data'])] if day['data']
          rescue StandardError => e
            e.rollbar_context = { solis_cloud_inverter_id: meter.meter_serial_number, date:, day: }
            raise
          end
        end
        [:solar_pv, { name: detail&.[]('name'), serial_number: meter.meter_serial_number, readings: }]
      end
    end

    def nearest_half_hour(time)
      time.dup.change(hour: time.hour + (time.min > 45 ? 1 : 0), min: time.min > 15 && time.min < 45 ? 30 : 0)
    end

    def zero_leftover(array)
      # first entries can sometimes be non zero
      index = array.find_index { |x| x < 1 }
      array.each_with_index { |_, i| array[i] = 0 if i < index } if index
    end

    def convert_invertor_day(data)
      half_hourly = data.pluck('timeStr', 'eToday')
                        .map { |time, total| [Time.parse(time).utc, total] }
                        .group_by { |time, _| nearest_half_hour(time) }
                        .map { |boundary, group| group.min_by { |time, _| (boundary - time).abs }[1] }
      zero_leftover(half_hourly)
      [half_hourly.first] + half_hourly[..47].each_cons(2).map { |prev, curr| curr - prev }
    end
  end
end
