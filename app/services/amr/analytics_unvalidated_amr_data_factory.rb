# frozen_string_literal: true

require 'dashboard'

module Amr
  class AnalyticsUnvalidatedAmrDataFactory
    def initialize(heat_meters: [], electricity_meters: [])
      @heat_meters = heat_meters
      @electricity_meters = electricity_meters
      @feed_configs = load_configs
      @all_readings_by_meter = load_all_readings
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

    # load just the data we need to convert data formats and enforce missing readings limit
    def load_configs
      AmrDataFeedConfig.select(:id, :date_format, :row_per_reading, :missing_readings_limit).index_by(&:id)
    end

    def all_meter_ids
      (@heat_meters + @electricity_meters).map(&:id)
    end

    def load_all_readings
      rows = AmrDataFeedReading
             .where(meter_id: all_meter_ids)
             .order(meter_id: :asc, created_at: :asc)
             .pluck(
               :meter_id,
               :amr_data_feed_config_id,
               :reading_date,
               :created_at,
               :readings
             )

      rows.group_by { |meter_id, *_| meter_id }
    end

    def readings_for_meter(active_record_meter)
      @all_readings_by_meter[active_record_meter.id] || []
    end

    def build_meter_data(active_record_meter)
      readings = readings_for_meter(active_record_meter).map do |(_, config_id, reading_date, created_at, values)|
        reading = [config_id, reading_date, created_at, values]
        reading_if_valid(active_record_meter.mpan_mprn, reading)
      end

      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings.compact)
    end

    def reading_if_valid(_meter_id, reading)
      return if reading_invalid?(reading)

      reading_date = date_from_string_using_date_format(reading)
      return if reading_date.nil?

      OneDayAMRReading.new(
        reading_date,
        'ORIG',
        nil,
        reading[2],
        reading[3].map(&:to_f)
      )
    end

    # Completely empty readingss are always invalid
    #
    # Otherwise reject if above the blank threshold for the config
    def reading_invalid?(reading)
      return true if reading[3].all?(&:blank?)

      blank_threshold = @feed_configs[reading[0]].blank_threshold
      if blank_threshold.present?
        reading[3].count(&:blank?) > blank_threshold
      else
        false
      end
    end

    def date_from_string_using_date_format(reading)
      date_format = @feed_configs[reading[0]].date_format
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
