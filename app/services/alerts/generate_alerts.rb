module Alerts
  class GenerateAlerts
    def initialize(
      school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity),
      alert_framework_adapter = FrameworkAdapter
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
      @alert_framework_adapter = alert_framework_adapter
    end

    def weekly
      perform(AlertType.weekly)
    end

    def termly
      perform(AlertType.termly)
    end

    def before_holiday
      perform(AlertType.before_each_holiday)
    end

  private

    def perform(alert_types_by_frequency)
      alerts = []
      alerts << get_alerts(alert_types_by_frequency.no_fuel, Time.zone.today)

      if @school.meters_with_validated_readings(:electricity).any?
        alerts << get_alerts(alert_types_by_frequency.electricity, @electricity_analysis_date)
      end

      if @school.meters_with_validated_readings(:gas).any?
        alerts << get_alerts(alert_types_by_frequency.gas, @gas_analysis_date)
      end
      alerts.flatten
    end

    def get_alerts(alert_types, analysis_date)
      alert_types.map do |alert_type|
        @alert_framework_adapter.new(alert_type, @school, analysis_date).analyse
      end
    end
  end
end
