module Recommendations
  class Base
    NUMBER_OF_SUGGESTIONS = 4

    def initialize(school)
      @school = school
    end

    def from_recent_activity(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = []

      completed = completed_ever

      # For each one, get the suggested intervention types and add them to the list until we have enough
      while (task = completed.shift) && suggestions.length < limit
        count_remaining = limit - suggestions.length
        suggestions += suggested_for(task, excluding: completed_this_year + suggestions).take(count_remaining)
      end

      suggestions + suggest_random(limit, suggestions: suggestions)
    end

    def completed_ever
      raise "Implement in subclass!"
    end

    def completed_this_year
      raise "Implement in subclass!"
    end

    def suggested_for(_task, _excluding: [])
      raise "Implement in subclass!"
    end
  end

  class Activity < Base
    #last_activity_type = @school.activities.order(:created_at).last.activity_type
  end

  class Action < Base
    def completed_ever
      @school.intervention_types_by_date
    end

    def completed_this_year
      @completed_this_year ||= @school.intervention_types_in_academic_year(Time.zone.now)
    end

    def suggested_for(task, excluding: [])
      task.suggested_types.not_including(excluding)
    end

    def suggest_random(limit, suggestions: [])
      return [] if suggestions.length >= limit

      InterventionType.not_custom.not_including(already_done + suggestions).sample(limit - suggestions.count)
    end
  end
end
