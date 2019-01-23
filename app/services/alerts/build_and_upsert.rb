module Alerts
  class BuildAndUpsert
    def initialize(
      school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity)
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
    end

    def perform
      alerts = BuildAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date).perform
      UpsertAlerts.new(alerts).perform
    end
  end
end
