module Audits
  class Progress
    attr_reader :audit

    def initialize(audit)
      @audit = audit
    end

    def recent?
      audit.created_at > 1.year.ago
    end

    def message
      i18n_key = recent? ? 'message_html' : 'message_older_html'

      I18n.t("schools.prompts.audit.#{i18n_key}",
        completed_activities_count: completed_activities_count,
        total_activities_count: total_activities_count,
        completed_actions_count: completed_actions_count,
        total_actions_count: total_actions_count
      )
    end

    def summary
      I18n.t('schools.prompts.audit.summary_html',
        remaining_points: remaining_points,
        count: bonus_points
      )
    end

    def notification
      (message + '<br />' + summary).html_safe
    end

    def completed_activities_count
      audit.activity_types_completed.count
    end

    def total_activities_count
      audit.activity_types.count
    end

    def completed_actions_count
      audit.intervention_types_completed.count
    end

    def total_actions_count
      audit.intervention_types.count
    end

    def remaining_activities_score
      audit.activity_types_remaining.sum(&:score)
    end

    def remaining_actions_score
      audit.intervention_types_remaining.sum(&:score)
    end

    def remaining_points
      remaining_activities_score + remaining_actions_score
    end

    def bonus_points
      audit.available_bonus_points
    end
  end
end
