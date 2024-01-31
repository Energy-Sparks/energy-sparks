module Recommendations
  class Activities < Base
    private

    def alert_tasks(alert)
      alert.activity_types
    end

    def audit_tasks
      school.audit_activity_types
    end

    def completed_ever
      @completed_ever ||= school.activity_types.merge(school.activities.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.activity_types_in_academic_year
    end

    def all_tasks
      ActivityType.all
    end
  end
end
