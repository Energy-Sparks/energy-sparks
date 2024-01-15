module Schools
  class EngagedSchoolService
    attr_reader :school

    def initialize(school)
      @school = school
    end

    def self.list_engaged_schools
      School.engaged.joins(:school_group).order('school_groups.name asc, name asc').map {|s| EngagedSchoolService.new(s) }
    end

    def school_group
      @school.school_group
    end

    def recent_activity_count
      @school.activities.where('created_at >= ?', since).count
    end

    def recent_action_count
      @school.observations.intervention.where('created_at >= ?', since).count
    end

    def recently_enrolled_programme_count
      @school.programmes.recently_started_non_default(since).count
    end

    def active_target?
      @active_target ||= @school.school_targets.currently_active.any?
    end

    def transport_surveys?
      @transport_surveys ||= @school.transport_surveys.recently_added(since).any?
    end

    def temperature_recordings?
      @temperature_recordings ||= @school.observations.temperature.where('created_at >= ?', since).any?
    end

    def audits?
      @audits ||= @school.observations.audit.where('created_at >= ?', since).any?
    end

    def recently_logged_in_user_count
      recently_logged_in.count
    end

    def most_recent_login
      @most_recent_login ||= recently_logged_in.pluck(:last_sign_in_at).max
    end

    private

    def recently_logged_in
      @recently_logged_in ||= @school.users.recently_logged_in(since)
    end

    def since
      @since ||= AcademicYear.current.start_date
    end
  end
end
