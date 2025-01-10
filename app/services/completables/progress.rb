module Completables
  class Progress
    def self.new(completable)
      "Completables::#{completable.class}".constantize.new(completable)
    end
  end

  class ProgressBase
    attr_reader :completable

    def initialize(completable)
      @completable = completable
    end

    def title
      ''
    end

    def assignable
      completable.assignable
    end

    def uncompleted_scores
      completable.uncompleted_tasks.sum(&:score)
    end

    def uncompleted_count
      completable.uncompleted_todos.count
    end

    def message
      I18n.t("schools.prompts.#{i18n_base}.#{i18n_message_key}",
        title: assignable.title,
        completed_activities_count: completable.completed_activity_types.count,
        total_activities_count: assignable.activity_type_todos.count,
        completed_actions_count: completable.completed_intervention_types.count,
        total_actions_count: assignable.intervention_type_todos.count
      )
    end

    def notification
      (message + '<br>' + summary).html_safe
    end
  end

  class Programme < ProgressBase
    def title
      assignable.title
    end

    def bonus_points
      assignable.bonus_score
    end

    def i18n_message_key
      if assignable.activity_type_todos.any? && assignable.intervention_type_todos.none?
        'message_activities_only_html'
      elsif assignable.activity_type_todos.none? && assignable.intervention_type_todos.any?
        'message_actions_only_html'
      else
        'message_html'
      end
    end

    def i18n_base
      'programme.progress'
    end

    def summary
      key = bonus_points > 0 ? 'summary_bonus_html' : 'summary_html'
      I18n.t("schools.prompts.#{i18n_base}.#{key}",
        count: uncompleted_count,
        uncompleted_scores: uncompleted_scores,
        bonus_points: bonus_points)
    end
  end

  class Audit < ProgressBase
    def i18n_base
      'audit'
    end

    def bonus_points
      completable.available_bonus_points
    end

    def recent?
      completable.created_at > 1.year.ago
    end

    def i18n_message_key
      recent? ? 'message_html' : 'message_older_html'
    end

    def summary
      I18n.t("schools.prompts.#{i18n_base}.summary_html",
        remaining_points: uncompleted_scores,
        count: bonus_points
      )
    end
  end
end
