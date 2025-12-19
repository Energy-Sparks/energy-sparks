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

    def available_count
      completable.assignable.todos.count
    end

    def completed_count
      completable.completed_todos.count
    end

    def uncompleted_count
      completable.uncompleted_todos.count
    end

    def bonus_points
      completable.available_bonus_points
    end

    def message
      I18n.t("schools.prompts.#{i18n_base}.#{i18n_message_key}",
        title: assignable.title,
        count: completed_count,
        completed_tasks_count: completed_count,
        total_tasks_count: available_count
      )
    end

    def summary
      key = if completed_count == 0
              'summary_none_html'
            elsif uncompleted_count == 1
              'summary_final_html'
            else
              'summary_html'
            end
      I18n.t("schools.prompts.#{i18n_base}.#{key}",
        count: bonus_points,
        uncompleted_count: uncompleted_count,
        uncompleted_scores: uncompleted_scores,
        bonus_points: bonus_points)
    end

    def notification
      (message + '<br>' + summary).html_safe
    end
  end

  class Programme < ProgressBase
    def title
      assignable.title
    end

    def i18n_message_key
      'message_html'
    end

    def i18n_base
      'programme.progress'
    end
  end

  class Audit < ProgressBase
    def i18n_base
      'audit.progress'
    end

    def recent?
      completable.created_at > 1.year.ago
    end

    def i18n_message_key
      recent? ? 'message_html' : 'message_older_html'
    end
  end
end
