module Targets
  class SuggestEstimatesService
    def initialize(school)
      @school = school
    end

    def suggestions(check_data: true)
      if check_data
        []
      else
        []
      end
    end

    def suggest_for_fuel_type?(_fuel_type, check_data: true)
      if check_data
        false
      else
        false
      end
    end

    private

    #if we have >8 months of data for this fuel type
    #before the target date, then move it

    def check_date_for_fuel_type
    end

    def months_between(first, second)
      ((first - second).to_f / 365 * 12).round
    end

    def candidate_suggestions
      @school.configuration.suggest_estimates_fuel_types
    end

    def school_target
      @school.most_recent_target
    end
  end
end
