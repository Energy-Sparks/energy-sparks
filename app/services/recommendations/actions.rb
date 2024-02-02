module Recommendations
  class Actions < Base
    private

    def alert_tasks(alert)
      alert.intervention_types
    end

    def audit_tasks
      school.audit_intervention_types
    end

    def task_tasks(task)
      task.suggested_types
    end

    def completed_ever
      @completed_ever ||= school.intervention_types.merge(school.observations.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.intervention_types_in_academic_year
    end

    def all_tasks
      InterventionType.not_custom
    end
  end
end
