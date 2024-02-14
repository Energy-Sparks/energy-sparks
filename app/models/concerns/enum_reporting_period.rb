module EnumReportingPeriod
  extend ActiveSupport::Concern

  # Add reporting periods as required:
  # [:financial_year, :academic_year]
  ENUM_REPORTING_PERIODS = {
    custom: 0,
    last_12_months: 1,
    last_2_school_weeks: 2,
    last_2_holidays: 3, # last holiday and the one before
    last_holiday_and_previous_year: 5, # last holiday and the same holiday last year
    current_holiday: 6
  }.freeze

  included do
    enum reporting_period: ENUM_REPORTING_PERIODS
  end
end
