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
        meter_data = build_meter_data(active_record_meter)

        # does meter have related sub meters?
        if active_record_meter.low_carbon_hub_installation.present?
          meter_data[:sub_meters] = build_sub_meters(active_record_meter)
        end

        meter_data
      end
      meters
    end

  private

    def build_sub_meters(active_record_meter)
      active_record_sub_meters = active_record_meter.low_carbon_hub_installation.meters.sub_meter
      active_record_sub_meters.map do |active_record_sub_meter|
        build_meter_data(active_record_sub_meter)
      end
    end

    def build_meter_data(active_record_meter)
      hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

      readings = AmrDataFeedReading.where(meter_id: active_record_meter.id).map do |reading|
        reading_if_valid(reading, hash_of_date_formats)
      end

      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings.compact)
    end

    def reading_if_valid(reading, hash_of_date_formats)
      return if reading_invalid?(reading)
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      return if reading_date.nil?
      {
        reading_date: reading_date,
        type: 'ORIG',
        upload_datetime: reading.created_at,
        kwh_data_x48: reading.readings.map(&:to_f)
      }
    end

    def reading_invalid?(reading)
      reading.readings.all?(&:blank?)
    end

    def date_from_string_using_date_format(reading, hash_of_date_formats)
      date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
      begin
        Date.strptime(reading.reading_date, date_format)
      rescue ArgumentError
        begin
          Date.parse(reading.reading_date)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
