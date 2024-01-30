module Audits
  class Progress
    attr_reader :audit

    def initialize(audit)
      @audit = audit
    end

    def message
      I18n.t('schools.prompts.audit.message_html',
        completed_activities_count: completed_activities_count,
        total_activities_count: total_activities_count,
        completed_actions_count: completed_actions_count,
        total_actions_count: total_actions_count
      )
    end

    def summary
      I18n.t('schools.prompts.audit.summary_html',
        remaining_points: remaining_points,
        bonus_points: bonus_points
      )
    end

    def notification
      (message + '<br />' + summary).html_safe
    end

    def completed_activities_count
      audit.completed_activity_types.count
    end

    def total_activities_count
      audit.activity_types.count
    end

    def completed_actions_count
      audit.completed_intervention_types.count
    end

    def total_actions_count
      audit.intervention_types.count
    end

    def remaining_activities_score
      audit.activity_types.sum(&:score) - audit.completed_activity_types.sum(&:score)
    end

    def remaining_actions_score
      audit.intervention_types.sum(&:score) - audit.completed_intervention_types.sum(&:score)
    end

    def remaining_points
      remaining_activities_score + remaining_actions_score
    end

    def bonus_points
      audit.available_bonus_points
    end
  end
end
