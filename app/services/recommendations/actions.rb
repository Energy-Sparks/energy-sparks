module Recommendations
  class Actions < Base
    private

    def tasks_for_alert(alert, excluding: [])
      alert.intervention_types.active.not_including(excluding)
    end

    def suggest_from_audits(count, excluding: [])
      count > 0 ? school.audit_intervention_types.active.not_including(excluding).limit(count) : []
    end

    def completed_ever
      @completed_ever ||= school.intervention_types.merge(school.observations.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.intervention_types_in_academic_year
    end

    def all(excluding: [])
      InterventionType.not_custom.not_including(excluding).active
    end
  end
end
