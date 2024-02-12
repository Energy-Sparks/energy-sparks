module EnumReportingPeriod
  extend ActiveSupport::Concern

  # Add reporting periods as required:
  # [:financial_year, :academic_year]
  ENUM_REPORTING_PERIODS = {
    custom: 0,
    last_12_months: 1,
  }.freeze

  included do
    enum reporting_period: ENUM_REPORTING_PERIODS
  end
end
