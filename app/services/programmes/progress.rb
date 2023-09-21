module Programmes
  class Progress
    def initialize(programme)
      @programme = programme
    end

    delegate :count, to: :programme_activities, prefix: :programme_activities
    delegate :count, to: :activity_types, prefix: :activity_types

    def title
      @programme.programme_type.title
    end

    # The number of activities, of the programme, that the school has completed.
    def programme_activities
      @programme.activities
    end

    # The number of different activity types associated with the programme.
    def activity_types
      programme.programme_type.activity_types
    end

    def activity_types_completed
      programme.activity_types_completed
    end
  end
end
