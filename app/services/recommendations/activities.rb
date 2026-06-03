module Recommendations
  class Activities < Base
    private

    def with_key_stage(scope)
      school.key_stages.any? ? scope.for_key_stages(school.key_stages) : scope
    end

    def alert_tasks(alert)
      with_key_stage(alert.activity_types)
    end

    def audit_tasks
      if Flipper.enabled?(:todos)
        with_key_stage(school.audit_activity_type_tasks)
      else
        with_key_stage(school.audit_activity_types)
      end
    end

    def task_tasks(task)
      with_key_stage(task.suggested_types)
    end

    def completed_ever
      @completed_ever ||= school.activity_types.merge(school.activities.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.activity_types_in_academic_year
    end

    def all_tasks
      with_key_stage(ActivityType.all)
    end
  end
end
