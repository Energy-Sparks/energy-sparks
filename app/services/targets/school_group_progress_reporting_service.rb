module Targets
  class SchoolGroupProgressReportingService
    def initialize(school_group)
      @school_group = school_group
    end

    def report
      school_progress = []
      schools.each do |school|
        begin
          school_progress << school_target_progress(school)
        rescue => e
          Rails.logger.error "Unable to generate progress report for #{school.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e, job: :school_progress_reporting, school_id: school.id, school: school.name)
        end
      end
      school_progress
    end

    private

    def schools
      @school_group.schools.process_data.by_name
    end

    def school_target_progress(school)
      targets_enabled = Targets::SchoolTargetService.targets_enabled?(school)
      if targets_enabled
        Targets::SchoolTargetsProgress.new(
          school: school,
          targets_enabled: targets_enabled,
          enough_data: enough_data?(school),
          progress_summary: progress_summary(school)
        )
      else
        Targets::SchoolTargetsProgress.new(
          school: school,
          targets_enabled: targets_enabled
        )
      end
    end

    def enough_data?(school)
      target_service(school).enough_data?
    end

    def target_service(school)
      Targets::SchoolTargetService.new(school)
    end

    def progress_summary(school)
      progress_service(school).progress_summary
    end

    def progress_service(school)
      Targets::ProgressService.new(school)
    end
  end
end
