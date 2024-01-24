module Recommendations
  class Action < Base
    private

    def completed_ever
      @completed_ever ||= school.intervention_types.merge(school.observations.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= school.intervention_types_in_academic_year
    end

    def all(excluding: [])
      InterventionType.not_custom.not_including(excluding)
    end
  end
end
