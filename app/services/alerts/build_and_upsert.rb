module Alerts
  class BuildAndUpsert
    def initialize(
      school,
      aggregate_school = AggregateSchoolService.new(school).aggregate_school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity),
      framework_adapter = FrameworkAdapter
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
      @aggregate_school = aggregate_school
      @framework_adapter = framework_adapter
    end

    def perform
      alerts = BuildAlerts.new(@school, @aggregate_school, @gas_analysis_date, @electricity_analysis_date, @framework_adapter).perform
      UpsertAlerts.new(alerts).perform
    end
  end
end
