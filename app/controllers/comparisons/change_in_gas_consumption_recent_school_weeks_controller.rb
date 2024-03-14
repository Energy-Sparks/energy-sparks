module Comparisons
  class ChangeInGasConsumptionRecentSchoolWeeksController < BaseController
    include ChangeInConsumption

    private

    def headers
      recent_school_weeks_headers
    end

    def key
      :change_in_gas_consumption_recent_school_weeks
    end

    def model
      Comparison::ChangeInGasConsumptionRecentSchoolWeeks
    end
  end
end
