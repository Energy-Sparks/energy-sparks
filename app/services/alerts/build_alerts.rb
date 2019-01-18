module Alerts
  class BuildAlerts
    def initialize(
      school,
      aggregate_school = AggregateSchoolService.new(school).aggregate_school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity),
      alert_framework_adapter = FrameworkAdapter
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
      @aggregate_school = aggregate_school
      @alert_framework_adapter = alert_framework_adapter
      @alerts = []
    end

    def perform
      @alerts << get_alerts(AlertType.no_fuel, Time.zone.today)

      if @school.meters_with_readings(:electricity).any?
        @alerts << get_alerts(AlertType.electricity, @electricity_analysis_date)
      end

      if @school.meters_with_readings(:gas).any?
        @alerts << get_alerts(AlertType.gas, @gas_analysis_date)
      end
      @alerts.flatten
    end

  private

    def get_alerts(alert_types, analysis_date)
      alert_types.map do |alert_type|
        @alert_framework_adapter.new(alert_type, @school, @aggregate_school, analysis_date).analyse
      end
    end
  end
end
