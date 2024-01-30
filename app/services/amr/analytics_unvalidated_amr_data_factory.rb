require 'dashboard'

module Amr
  class AnalyticsUnvalidatedAmrDataFactory
    def initialize(heat_meters: [], electricity_meters: [])
      @heat_meters = heat_meters
      @electricity_meters = electricity_meters
    end

    def build
      meters = {}
      meters[:heat_meters] = @heat_meters.map do |active_record_meter|
        build_meter_data(active_record_meter)
      end

      meters[:electricity_meters] = @electricity_meters.map do |active_record_meter|
        build_meter_data(active_record_meter)
      end
      meters
    end

  private

    def build_meter_data(active_record_meter)
      hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

      readings = AmrDataFeedReading.order(created_at: :asc)
        .where(meter_id: active_record_meter.id)
        .pluck(:amr_data_feed_config_id, :reading_date, :created_at, :readings).map do |reading|
        reading_if_valid(active_record_meter.mpan_mprn, reading, hash_of_date_formats)
      end

      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings.compact)
    end

    def reading_if_valid(meter_id, reading, hash_of_date_formats)
      return if reading_invalid?(reading)
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      return if reading_date.nil?
      OneDayAMRReading.new(
        meter_id,
        reading_date,
        'ORIG',
        nil,
        reading[2],
        reading[3].map(&:to_f)
      )
    end

    def reading_invalid?(reading)
      reading[3].all?(&:blank?)
    end

    def date_from_string_using_date_format(reading, hash_of_date_formats)
      date_format = hash_of_date_formats[reading[0]]
      begin
        Date.strptime(reading[1], date_format)
      rescue ArgumentError
        begin
          Date.parse(reading[1])
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
