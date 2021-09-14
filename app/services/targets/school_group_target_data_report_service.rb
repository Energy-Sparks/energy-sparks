module Targets
  class SchoolGroupTargetDataReportService
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

    #returns hash school => hash(fuel_type => results)
    def test_targets
      report = {}
      fuel_type_report = {
        enough_data: false,
        success: false,
        progress: nil,
        error: nil
      }
      schools.each do |school|
        report[school] = {
          electricity: fuel_type_report.dup,
          gas: fuel_type_report.dup,
          storage_heaters: fuel_type_report.dup
        }
        begin
          unless school.has_target?
            target = Targets::SchoolTargetService.new(school).build_target
            target.save!
          end

          #Create meter collection without hitting the cache
          aggregate_school = Amr::AnalyticsMeterCollectionFactory.new(school).validated
          AggregateDataService.new(aggregate_school).aggregate_heat_and_electricity_meters

          #Loop through each fuel type
          # rubocop:disable Performance/CollectionLiteralInLoop
          [:electricity, :gas, :storage_heaters].each do |fuel_type|
            target_service = ::TargetsService.new(aggregate_school, fuel_type)
            begin
              #If school has that fuel type and there's enough data
              if school.send("has_#{fuel_type}?".to_sym) && target_service.meter_present? && target_service.enough_data_to_set_target?
                #record we have enough data
                report[school][fuel_type][:enough_data] = true
                report[school][fuel_type][:recent_data] = target_service.recent_data?
                #request the latest cumulative performance
                progress = target_service.progress.current_cumulative_performance
                #record success and figure
                report[school][fuel_type].merge!(success: true, progress: progress)
              end
            rescue => e
              puts "#{school.name} - #{fuel_type}"
              puts e.message
              puts e.backtrace
              report[school][fuel_type][:error] = e.message
              Rails.logger.error "Unable to generate report for #{school.name}: #{e.message}"
              Rails.logger.error e.backtrace.join("\n")
              Rollbar.error(e, job: :test_targets, school: school)
            end
          end
          # rubocop:enable Performance/CollectionLiteralInLoop
        rescue => e
          puts e.message
          puts e.backtrace
          Rails.logger.error "Unable to generate report for #{school.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e, job: :test_targets, school: school)
        end
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
