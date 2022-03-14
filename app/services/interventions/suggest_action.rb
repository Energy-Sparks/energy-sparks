module Interventions
  class SuggestAction
    NUMBER_OF_SUGGESTIONS = 6

    def initialize(school)
      @school = school
    end

    #This is just an initial implementation to hook in suggesting based on
    #alerts, needs further improvements
    def suggest(limit = 5)
      suggestions = suggest_from_audits.to_a
      return suggestions.take(limit) unless suggestions.length < limit

      top_up_from_list(suggest_from_alerts.to_a, suggestions)
      return suggestions.take(limit) unless suggestions.length < limit

      top_up_from_list(InterventionType.not_other.sample(limit), suggestions)
      suggestions.take(limit)
    end

    def suggest_from_audits
      @school.audits.map(&:intervention_types).flatten.uniq
    end

    def suggest_from_alerts
      content = @school.latest_content
      if content
        content.find_out_more_intervention_types.uniq
      else
        InterventionType.none
      end
    end

    private

    def top_up_from_list(more, suggestions)
      more.each do |suggestion|
        suggestions << suggestion unless suggestions.include?(suggestion)
      end
    end
  end
end
