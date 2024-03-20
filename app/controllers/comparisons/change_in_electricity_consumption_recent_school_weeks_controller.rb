# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityConsumptionRecentSchoolWeeksController < Shared::ChangeInConsumptionController
    private

    def headers
      recent_school_weeks_headers
    end

    def key
      :change_in_electricity_consumption_recent_school_weeks
    end

    def model
      Comparison::ChangeInElectricityConsumptionRecentSchoolWeeks
    end
  end
end
