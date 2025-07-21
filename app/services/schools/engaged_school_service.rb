# frozen_string_literal: true

module Schools
  class EngagedSchoolService
    attr_reader :school

    def initialize(school, date_range)
      @school = school
      @date_range = date_range
    end

    def self.engaged_schools_count
      School.engaged(AcademicYear.current.start_date..).count
    end

    def self.list_schools(previous_year, school_group_id)
      current_year = AcademicYear.current
      date_range = if previous_year
                     previous_year = current_year.previous_year
                     previous_year.start_date..previous_year.end_date
                   else
                     current_year.start_date..
                   end
      schools = School.joins(:school_group)
      schools = schools.where(school_group_id: school_group_id) if school_group_id.present?
      schools.order('school_groups.name asc, name asc').map do |school|
        EngagedSchoolService.new(school, date_range)
      end
    end

    def school_group
      @school.school_group
    end

    def recent_activity_count
      @school.activities.where(created_at: @date_range).count
    end

    def recent_action_count
      @school.observations.intervention.where(created_at: @date_range).count
    end

    def recently_enrolled_programme_count
      @school.programmes.recently_started_non_default(@date_range).count
    end

    def active_target?
      @active_target ||= @school.school_targets.where(target_date: @date_range).any?
    end

    def transport_surveys?
      @transport_surveys ||= @school.transport_surveys.recently_added(@date_range).any?
    end

    def temperature_recordings?
      @temperature_recordings ||= @school.observations.temperature.where(created_at: @date_range).any?
    end

    def audits?
      @audits ||= @school.observations.audit.where(created_at: @date_range).any?
    end

    def recently_logged_in_user_count
      recently_logged_in.count
    end

    def most_recent_login
      @most_recent_login ||= recently_logged_in.pluck(:last_sign_in_at).max
    end

    private

    def recently_logged_in
      @recently_logged_in ||= User.left_outer_joins(:cluster_schools_users)
                                  .where(cluster_schools_users: { school_id: @school })
                                  .or(@school.users)
                                  .distinct
                                  .recently_logged_in(@date_range.begin)
    end
  end
end
