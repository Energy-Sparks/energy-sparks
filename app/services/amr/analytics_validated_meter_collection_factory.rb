require 'dashboard'

module Amr
  class AnalyticsValidatedMeterCollectionFactory
    def initialize(active_record_school, meter_collection_class = MeterCollection)
      @active_record_school = active_record_school
      @meter_collection_class = meter_collection_class
      @dashboard_school = AnalyticsSchoolFactory.new(active_record_school).build
    end

    def build
      @meter_collection = @meter_collection_class.new(@dashboard_school, ScheduleDataManagerService.new(@active_record_school))
      add_meters_and_amr_validated_data
    end

  private

    def add_meters_and_amr_validated_data
      @active_record_school.meters_with_validated_readings(:gas).map do |active_record_meter|
        dashboard_meter = add_validated_amr_data(active_record_meter)
        @meter_collection.add_heat_meter(dashboard_meter)
      end

      @active_record_school.meters_with_validated_readings(:electricity).map do |active_record_meter|
        dashboard_meter = add_validated_amr_data(active_record_meter)
        @meter_collection.add_electricity_meter(dashboard_meter)
      end
      @meter_collection
    end

    def add_validated_amr_data(active_record_meter)
      dashboard_meter = Amr::AnalyticsMeterFactory.new(active_record_meter, @meter_collection).build

      validated_reading_array = AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).pluck(:reading_date, :status, :substitute_date, :upload_datetime, :kwh_data_x48)
      validated_reading_array.each do |reading|
        dashboard_meter.amr_data.add(reading[0], OneDayAMRReading.new(active_record_meter.id, reading[0], reading[1], reading[2], reading[3], reading[4].map(&:to_f)))
      end

      dashboard_meter
    end
  end
end
