module Alerts
  class GenerateAndSaveAlerts
    def initialize(
      school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity)
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
    end

    def weekly_alerts
      alerts = GenerateAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date).weekly
      UpsertAlerts.new(alerts).perform
    end

    def termly_alerts
      alerts = GenerateAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date).termly
      UpsertAlerts.new(alerts).perform
    end

    def before_holiday_alerts
      alerts = GenerateAlerts.new(@school, @gas_analysis_date, @electricity_analysis_date).before_holiday
      UpsertAlerts.new(alerts).perform
    end
  end
end
