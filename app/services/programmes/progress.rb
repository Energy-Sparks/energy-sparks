module Programmes
  class Progress
    attr_reader :programme
    def initialize(programme)
      @programme = programme
    end

    # The number of activities, of the programme, that the school has completed.
    delegate :count, to: :programme_activities, prefix: :programme_activities
    # The number of different activity types associated with the programme.
    delegate :count, to: :activity_types, prefix: :activity_types
    # The number of different activity types associated with the programme that have been completed.
    delegate :count, to: :activity_types_completed, prefix: :activity_types_completed

    def message
      I18n.t('schools.prompts.programme.message_html',
        programme_type_title: programme_type_title,
        programme_activities_count: programme_activities_count,
        activity_types_count: activity_types_count,
        activity_types_total_scores: activity_types_total_scores)
    end

    def summary
      key = programme_points_for_completion > 0 ? 'summary_bonus_html' : 'summary_html'
      I18n.t("schools.prompts.programme.#{key}",
        count: activity_types_uncompleted_count,
        activity_types_uncompleted_scores: activity_types_uncompleted_scores,
        programme_points_for_completion: programme_points_for_completion)
    end

    def notification
      (message + "<br />" + summary).html_safe
    end

    def activity_types_total_scores
      activity_types.sum(:score)
    end

    def programme_points_for_completion
      programme.points_for_completion
    end

    def programme_type_title
      programme.programme_type.title
    end

    def programme_activities
      programme.activities
    end

    def activity_types
      programme.programme_type.activity_types
    end

    def activity_types_completed
      programme.activity_types_completed
    end

    def activity_types_completed_scores
      programme.activity_types_completed.sum(&:score)
    end

    def activity_types_uncompleted_scores
      activity_types_total_scores - activity_types_completed_scores
    end

    def activity_types_uncompleted_count
      activity_types_count - activity_types_completed_count
    end
  end
end
