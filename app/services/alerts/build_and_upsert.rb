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

    # def perform
    #   generate_weekly_alerts
    #   generate_termly_alerts
    #   generate_before_holiday_alerts
    # end

    def generate_weekly_alerts
      alerts = BuildAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date, AlertType.weekly).perform
      UpsertAlerts.new(alerts).perform
    end

    def generate_termly_alerts
      alerts = BuildAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date, AlertType.termly).perform
      UpsertAlerts.new(alerts).perform
    end

    def generate_before_holiday_alerts
      alerts = BuildAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date, AlertType.before_each_holiday).perform
      UpsertAlerts.new(alerts).perform
    end
  end
end
