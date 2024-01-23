module Recommendations
  class Base
    NUMBER_OF_SUGGESTIONS = 4

    def initialize(school)
      @school = school
    end

    def from_recent_activity(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = []

      # get tasks completed, most recent first
      completed = completed_ever

      # For each one, get the suggested types and add them to the list until we have enough
      while (task = completed.shift) && suggestions.length < limit
        count_remaining = limit - suggestions.length
        suggestions += suggested_for(task, excluding: completed_this_year + suggestions).take(count_remaining)
      end

      suggestions + suggest_random(limit, suggestions: suggestions)
    end

    def suggest_random(limit, suggestions: [])
      return [] if suggestions.length >= limit

      all_tasks(excluding: completed_this_year + suggestions).sample(limit - suggestions.count)
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
    def completed_ever
      @school.activity_types.by_activity_date # newest first
    end

    def compeleted_this_year
    end
  end

  class Action < Base
    def completed_ever
      @school.intervention_types.by_observation_date # newest first
    end

    def completed_this_year
      @completed_this_year ||= @school.intervention_types_in_academic_year(Time.zone.now)
    end

    def suggested_for(task, excluding: [])
      task.suggested_types.not_including(excluding)
    end

    def all_tasks(excluding: [])
      InterventionType.not_custom.not_including(excluding)
    end
  end
end
