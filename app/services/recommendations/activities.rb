module Recommendations
  class Activities < Base
    private

    def tasks_for_alert(alert, excluding: [])
      alert.activity_types.active.not_including(excluding)
    end

    def suggest_from_audits(count, excluding: [])
      count > 0 ? school.audit_activity_types.active.not_including(excluding).limit(count) : []
    end

    def completed_ever
      @completed_ever ||= school.activity_types.merge(school.activities.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.activity_types_in_academic_year
    end

    def all(excluding: [])
      ActivityType.not_including(excluding).active
    end
  end
end
