module Programmes
  class Progress
    attr_reader :programme
    def initialize(programme)
      @programme = programme
    end

    delegate :count, to: :programme_activities, prefix: :programme_activities
    delegate :count, to: :activity_types, prefix: :activity_types
    delegate :count, to: :activity_types_completed, prefix: :activity_types_completed

    def text
      "You have completed #{programme_activities_count}/#{activity_types_count} of the activities in the #{title} programme. Complete the final #{activity_types_uncompleted_count} activities now to score #{total_points} points"
    end

    def total_points
      activity_types.sum(:score) + programme.programme_type.bonus_score
    end

    def title
      programme.programme_type.title
    end

    # The number of activities, of the programme, that the school has completed.
    def programme_activities
      programme.activities
    end

    # The number of different activity types associated with the programme.
    def activity_types
      programme.programme_type.activity_types
    end

    def activity_types_completed
      programme.activity_types_completed
    end

    def activity_types_uncompleted_count
      activity_types_count - activity_types_completed_count
    end
  end
end
