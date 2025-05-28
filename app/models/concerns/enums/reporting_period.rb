# frozen_string_literal: true


module Enums::ReportingPeriod
  extend ActiveSupport::Concern

  # Add reporting periods as required:
  # [:financial_year, :academic_year]
  ENUM_REPORTING_PERIODS = {
    custom: 0,
    last_12_months: 1,
    last_2_weeks: 2,
    last_2_holidays: 3,
    same_holidays: 4,
    current_holidays: 5
  }.freeze

  included do
    enum :reporting_period, ENUM_REPORTING_PERIODS
  end
end
