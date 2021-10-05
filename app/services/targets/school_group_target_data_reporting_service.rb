module Targets
  class SchoolGroupTargetDataReportingService
    def initialize(school_group)
      @school_group = school_group
    end

    #returns hash school => result
    def report
      report = {}
      schools.each do |school|
        begin
          aggregate_school = AggregateSchoolService.new(school).aggregate_school
          report[school] = report_for_school(school, aggregate_school)
        rescue => e
          report[school] = []
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
      ::TargetsService.new(aggregate_school, fuel_type)
    end

    def report_for_school(school, aggregate_school)
      result = []
      result << report_for_school_and_fuel_type(school, aggregate_school, :electricity) if school.has_electricity?
      result << report_for_school_and_fuel_type(school, aggregate_school, :gas) if school.has_gas?
      result << report_for_school_and_fuel_type(school, aggregate_school, :storage_heater) if school.has_storage_heaters?
      result
    end

    def report_for_school_and_fuel_type(school, aggregate_school, fuel_type)
      service = target_service(aggregate_school, fuel_type)
      {
        fuel_type: fuel_type,
        holidays: service.enough_holidays?,
        temperature: service.enough_temperature_data?,
        readings: service.enough_readings_to_calculate_target?,
        estimate_needed: service.annual_kwh_estimate_required?,
        estimate_set: service.annual_kwh_estimate?,
        target: service.target_set?,
        current_target: school.has_current_target?
      }
    end
  end
end
