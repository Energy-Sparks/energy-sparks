# frozen_string_literal: true

module Solar
  class SolisCloudDownloadAndUpsert < BaseDownloadAndUpsert
    def download_and_upsert
      readings = download
      SolisCloudUpserter.new(installation: @installation, readings: readings, import_log: import_log).perform
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

    def start_date(station = {})
      if @requested_start_date
        @requested_start_date
      elsif latest_reading
        latest_reading - 5.days
      elsif station['createDate']
        Time.at(station['createDate'] / 1000.0).utc.to_date
      else
        raise 'unknown start date'
      end
    end

    def download
      api = DataFeeds::SolisCloudApi.new(@installation.api_id, @installation.api_secret)
      stations = api.user_station_list.dig('data', 'page', 'records') || []
      @installation.update!(station_list: stations)
      stations.map do |station|
        station[:readings] = (start_date(station)..end_date).filter_map do |date|
          Rails.logger.debug { "SolisCloud download for #{station['id']} #{date}" }
          begin
            station_day = api.station_day(station['id'], date)
            # sometimes the data attribute can be nil
            [date, create_kwh_data_x48(station_day['data'])] if station_day['data']
          rescue StandardError => e
            e.rollbar_context = { station_id: station['id'], date:, station_day: }
            raise
          end
        end
        [:solar_pv, station]
      end
    end
  end
end
