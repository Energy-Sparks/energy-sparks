module Recommendations
  class Base
    NUMBER_OF_SUGGESTIONS = 4

    attr_reader :school

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

      all(excluding: completed_this_year + suggestions).sample(limit - suggestions.count)
    end

    private

    def suggested_for(task, excluding: [])
      task.suggested_types.not_including(excluding)
    end

    def completed_ever
      raise "Implement in subclass!"
    end

    def completed_this_year
      raise "Implement in subclass!"
    end

    def all(_excluding: [])
      raise "Implement in subclass!"
    end
  end
end
