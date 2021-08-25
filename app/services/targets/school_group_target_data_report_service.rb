module Targets
  class SchoolGroupTargetDataReportService
    def initialize(school_group)
      @school_group = school_group
    end

    #returns hash school => result
    def report
      report = {}
      schools.each do |school|
        aggregate_school = AggregateSchoolService.new(school).aggregate_school
        report[school] = report_for_school(school, aggregate_school)
      end
      report
    end

    private

    def schools
      @school_group.schools.by_name
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
        calendar_data: service.enough_holidays?,
        amr_data: service.enough_readings_to_calculate_target?,
        current_target: school.has_current_target?
      }
    end
  end
end
