module Alerts
  class GenerateAndSaveAlerts
    def initialize(
      school,
      alert_framework_adapter = FrameworkAdapter
    )
      @school = school
      @alert_framework_adapter = alert_framework_adapter
    end

    def weekly_alerts
      perform(AlertType.weekly)
    end

    def termly_alerts
      perform(AlertType.termly)
    end

    def before_holiday_alerts
      perform(AlertType.before_each_holiday)
    end

  private

    def perform(alert_types_by_frequency)
      generate(alert_types_by_frequency.no_fuel)

      if @school.meters_with_validated_readings(:electricity).any?
        generate(alert_types_by_frequency.electricity)
      end

      if @school.meters_with_validated_readings(:gas).any?
        generate(alert_types_by_frequency.gas)
      end
    end

    def generate(alert_types)
      alert_types.map do |alert_type|
        alert = @alert_framework_adapter.new(alert_type, @school).analyse
        alert.save
      end
    end
  end
end
