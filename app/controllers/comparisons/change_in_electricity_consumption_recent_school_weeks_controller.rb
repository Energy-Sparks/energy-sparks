# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityConsumptionRecentSchoolWeeksController < BaseController
    include ChangeInConsumption

    private

    def headers
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.change_pct'),
       t('analytics.benchmarking.configuration.column_headings.change_£current'),
       t('analytics.benchmarking.configuration.column_headings.change_kwh')]
    end

    def key
      :change_in_electricity_consumption_recent_school_weeks
    end

    def model
      Comparison::ChangeInElectricityConsumptionRecentSchoolWeeks
    end
  end
end
