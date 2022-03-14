module Interventions
  class SuggestAction
    NUMBER_OF_SUGGESTIONS = 6

    def initialize(school)
      @school = school
    end

    def suggest(limit = 5)
      suggestions = []
      suggestions = top_up_from_list(suggest_from_audits, suggestions)
      suggestions = top_up_from_list(suggest_from_alerts, suggestions) if suggestions.length < limit
      suggestions = top_up_from_list(suggest_random(limit), suggestions) if suggestions.length < limit
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

    def suggest_random(limit)
      InterventionType.not_other.sample(limit)
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
