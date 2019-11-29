require 'dashboard'

module Amr
  class AnalyticsMeterCollectionFactory
    def initialize(active_record_school, meter_collection_class = MeterCollectionFactory)
      @active_record_school = active_record_school
      @meter_collection_class = meter_collection_class
    end

    def unvalidated
      @meter_collection_class.build(unvalidated_data)
    end

    def unvalidated_data
      heat_meters = @active_record_school.meters_with_readings(:gas)
      electricity_meters = @active_record_school.meters_with_readings(Meter.non_gas_meter_types)
      data(AnalyticsUnvalidatedAmrDataFactory, heat_meters, electricity_meters)
    end

    def validated
      @meter_collection_class.build(validated_data)
    end

    def validated_data
      heat_meters = @active_record_school.meters_with_validated_readings(:gas)
      electricity_meters = @active_record_school.meters_with_validated_readings(:electricity)
      data(AnalyticsValidatedAmrDataFactory, heat_meters, electricity_meters)
    end

    def aggregated_data(meter_data)
      {
        school_data: AnalyticsSchoolFactory.new(@active_record_school).build,
        schedule_data: schedule_data,
        meter_data: meter_data,
        pseudo_meter_attributes: MeterAttribute.pseudo_for(@active_record_school.urn)
      }
    end

    def aggregated(meter_data)
      @meter_collection_class.build_with_meter_data(aggregated_data(meter_data))
    end

    private

    def schedule_data
      schedule_data_manager_service = ScheduleDataManagerService.new(@active_record_school)
      {
        temperatures: schedule_data_manager_service.temperatures,
        solar_pv: schedule_data_manager_service.solar_pv,
        solar_irradiation: schedule_data_manager_service.solar_irradiation,
        grid_carbon_intensity: schedule_data_manager_service.uk_grid_carbon_intensity,
        holidays: schedule_data_manager_service.holidays
      }
    end

    def data(meter_data_class, heat_meters, electricity_meters)
      {
        school_data: AnalyticsSchoolFactory.new(@active_record_school).build,
        schedule_data: schedule_data,
        amr_data: meter_data_class.new(heat_meters: heat_meters, electricity_meters: electricity_meters).build,
        pseudo_meter_attributes: MeterAttribute.pseudo_for(@active_record_school.urn)
      }
    end
  end
end
