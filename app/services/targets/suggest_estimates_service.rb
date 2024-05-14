module Targets
  class SuggestEstimatesService
    # how many months of data before the target start date do we need to
    # have before we consider it not always worth nudging for an estimate
    THRESHOLD_FOR_FILTERING = 8

    def initialize(school)
      @school = school
    end

    # By default return what analytics has indicated, otherwise filter to just
    # those fuel types where an estimate will significantly improve the report
    def suggestions(check_data: false)
      if check_data
        candidate_suggestions.select { |fuel_type| include_fuel_type_in_suggestions?(fuel_type) }
      else
        candidate_suggestions
      end
    end

    # Should we prompt for an estimate for this fuel type?
    #
    # by default we'll just go with what analytics has suggested
    # but sometimes we want to ignore the suggestion if we have a reasonable
    # amount of data. Avoids asking the user to supply an estimate if it will only
    # add in a couple of months of additional targets
    def suggest_for_fuel_type?(fuel_type, check_data: false)
      if check_data
        include_fuel_type_in_suggestions?(fuel_type)
      else
        @school.configuration.suggest_annual_estimate_for_fuel_type?(fuel_type)
      end
    end

    private

    # if we have >8 months of data for this fuel type
    # before the target date, then remove it
    def include_fuel_type_in_suggestions?(fuel_type)
      return false unless school_target
      return false unless @school.configuration.suggest_annual_estimate_for_fuel_type?(fuel_type)
      target_start_date = school_target.start_date
      fuel_type_start = @school.configuration.meter_start_date(fuel_type)
      # default to including if no data, or if target is before data starts
      # then dont suggest
      if fuel_type_start.nil? || target_start_date <= fuel_type_start
        false
      # if we have more than 8 months of data, then we're close to having a full
      # year so dont prompt
      else
        months_between(target_start_date, fuel_type_start) <= THRESHOLD_FOR_FILTERING
      end
    end

    def months_between(first, second)
      ((first - second).to_f / 365 * 12).floor
    end

    def candidate_suggestions
      @school.configuration.suggest_estimates_fuel_types
    end

    def school_target
      @school.most_recent_target
    end
  end
end
