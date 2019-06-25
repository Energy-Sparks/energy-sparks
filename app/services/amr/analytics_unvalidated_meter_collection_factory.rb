require 'dashboard'

module Amr
  class AnalyticsUnvalidatedMeterCollectionFactory
    def initialize(active_record_school, meter_collection_class = MeterCollection)
      @active_record_school = active_record_school
      @meter_collection_class = meter_collection_class
      @dashboard_school = AnalyticsSchoolFactory.new(active_record_school).build
    end

    def build
      return unless any_meters_with_readings?

      @meter_collection = @meter_collection_class.new(@dashboard_school, ScheduleDataManagerService.new(@active_record_school))
      add_meters_and_amr_data
    end

  private

    def add_meters_and_amr_data
      heat_meters.map do |active_record_meter|
        dashboard_meter = add_amr_data(active_record_meter)
        @meter_collection.add_heat_meter(dashboard_meter)
      end

      electricity_meters.map do |active_record_meter|
        dashboard_meter = add_amr_data(active_record_meter)
        @meter_collection.add_electricity_meter(dashboard_meter)
      end
      @meter_collection
    end

    def heat_meters
      @active_record_school.meters_with_readings(:gas)
    end

    def electricity_meters
      @active_record_school.meters_with_readings(:electricity)
    end

    def any_meters_with_readings?
      @active_record_school.meters_with_readings.any?
    end

    def add_amr_data(active_record_meter)
      dashboard_meter = Amr::AnalyticsMeterFactory.new(active_record_meter, @meter_collection).build

      hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

      AmrDataFeedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).each do |reading|
        add_reading_if_valid(active_record_meter, dashboard_meter, reading, hash_of_date_formats)
      end

      dashboard_meter
    end

    def add_reading_if_valid(active_record_meter, dashboard_meter, reading, hash_of_date_formats)
      return if reading_invalid?(reading)
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      return if reading_date.nil?
      dashboard_meter.amr_data.add(reading_date, OneDayAMRReading.new(active_record_meter.id, reading_date, 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    def reading_invalid?(reading)
      reading.readings.all?(&:blank?)
    end

    def date_from_string_using_date_format(reading, hash_of_date_formats)
      date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
      begin
        Date.strptime(reading.reading_date, date_format)
      rescue ArgumentError
        nil
      end
    end
  end
end
