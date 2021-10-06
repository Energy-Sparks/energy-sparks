module Targets
  # This service is used as part of bulk testing the targets and tracking feature
  # It should NOT be run on the production service
  class SchoolGroupTargetsTestingService
    def initialize(school_group)
      @school_group = school_group
    end

    #returns hash school => hash(fuel_type => results)
    def report
      report = {}
      fuel_type_report = {
        enough_data: false,
        recent_data: "N/A",
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
          school_target_service = Targets::SchoolTargetService.new(school)
          #only test schools where we believe feature should work
          next unless school_target_service.enough_data?

          #generate a default target unless we have one
          unless school.has_target?
            target = school_target_service.build_target
            target.save!
          end

          #Create meter collection without hitting the application cache
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
              Rollbar.error(e, job: :test_targets, school: school.name)
            end
          end
          # rubocop:enable Performance/CollectionLiteralInLoop
        rescue => e
          puts school.name
          puts e.message
          puts e.backtrace
          Rails.logger.error "Unable to generate report for #{school.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e, job: :test_targets, school: school.name)
        end
      end
      report
    end

    private

    def schools
      @school_group.schools.process_data.by_name
    end
  end
end
