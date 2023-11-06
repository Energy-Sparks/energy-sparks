module Interventions
  class SuggestAction
    NUMBER_OF_SUGGESTIONS = 4

    def initialize(school)
      @school = school
    end

    def suggest(limit = 5)
      suggestions = []
      suggestions = top_up_from_list(suggest_from_audits, suggestions)
      suggestions = top_up_from_list(suggest_from_alerts, suggestions) if suggestions.length < limit
      suggestions = top_up_from_list(suggest_from_most_recent_intervention, suggestions) if suggestions.length < limit
      suggestions = top_up_from_list(suggest_random(limit), suggestions) if suggestions.length < limit
      suggestions.take(limit)
    end

    def suggest_from_audits
      @school.audits.map(&:intervention_types).flatten
    end

    def suggest_from_alerts
      content = @school.latest_content
      if content
        content.find_out_more_intervention_types
      else
        []
      end
    end

    def suggest_from_most_recent_intervention
      if (most_recent_intervention_type = @school.intervention_types_by_date.first)
        most_recent_intervention_type.suggested_types
      else
        []
      end
    end

    def suggest_random(limit, suggestions: [])
      if suggestions.length < limit
        InterventionType.not_custom.not_including(already_done + suggestions).sample(limit - suggestions.count)
      else
        [] # We already have enough
      end
    end

    ## For prototyping. Actual algorithm to be defined ##
    def suggest_from_recent_activity(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = []

      # Get completed intervention types for school in reverse order (most recent is first)
      intervention_types = @school.intervention_types_by_date

      # For each one, get the suggested intervention types and add them to the list until we have enough
      while (intervention_type = intervention_types.shift) && suggestions.length < limit
        suggestions += intervention_type.suggested_types.not_including(already_done + suggestions).take(limit - suggestions.length)
      end

      suggestions + suggest_random(limit, suggestions: suggestions)
    end

    def suggest_from_energy_usage(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = suggest_from_alerts.take(limit)

      suggestions + suggest_random(limit, suggestions: suggestions)
    end

    private

    def already_done
      @already_done ||= @school.intervention_types_in_academic_year(Time.zone.now)
    end

    def top_up_from_list(more, suggestions)
      more.to_a.each do |suggestion|
        suggestions << suggestion unless suggestions.include?(suggestion) || already_done.include?(suggestion)
      end
      suggestions
    end
  end
end
