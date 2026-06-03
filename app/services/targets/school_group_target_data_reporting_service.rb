module Targets
  class SchoolGroupTargetDataReportingService
    def initialize(school_group)
      @school_group = school_group
    end

    # returns Hash of School => Struct(school:, electricity: , gas:, storage_heater:)
    def report
      report = {}
      schools.each do |school|
        begin
          aggregate_school = AggregateSchoolService.new(school).aggregate_school
          report[school] = report_for_school(school, aggregate_school)
        rescue => e
          report[school] = nil
          Rails.logger.error "Unable to generate report for #{school.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e, job: :target_data, school: school)
        end
      end
      report
    end

    private

    def schools
      @school_group.schools.process_data.by_name
    end

    def target_service(aggregate_school, fuel_type)
      TargetsService.new(aggregate_school, fuel_type)
    end

    # OpenStruct to group them
    def report_for_school(school, aggregate_school)
      result = OpenStruct.new(school: school)
      result.electricity = report_for_school_and_fuel_type(school, aggregate_school, :electricity) if school.has_electricity?
      result.gas = report_for_school_and_fuel_type(school, aggregate_school, :gas) if school.has_gas?
      result.storage_heater = report_for_school_and_fuel_type(school, aggregate_school, :storage_heater) if school.has_storage_heaters?
      result
    end

    # OpenStruct, move to target service?
    def report_for_school_and_fuel_type(school, aggregate_school, fuel_type)
      service = target_service(aggregate_school, fuel_type)
      OpenStruct.new(
        fuel_type: fuel_type,
        holidays: service.enough_holidays?,
        temperature: service.enough_temperature_data?,
        readings: service.enough_readings_to_calculate_target?,
        estimate_needed: service.annual_kwh_estimate_required?,
        estimate_set: service.annual_kwh_estimate?,
        calculate_synthetic_data: service.can_calculate_one_year_of_synthetic_data?,
        target_set: school.has_current_target?,
        recent_data: service.recent_data?
      )
    end
  end
end
