module Alerts
  class GenerateAndSaveAlerts
    def initialize(
      school,
      alert_framework_adapter = FrameworkAdapter
    )
      @school = school
      @alert_framework_adapter = alert_framework_adapter
    end

    def perform
      generate(AlertType.no_fuel)

      if @school.meters_with_validated_readings(:electricity).any?
        generate(AlertType.electricity)
      end

      if @school.meters_with_validated_readings(:gas).any?
        generate(AlertType.gas)
      end
    end

  private

    def generate(alert_types)
      alert_types.each do |alert_type|
        alert = @alert_framework_adapter.new(alert_type, @school).analyse
        alert.save
      end
    end
  end
end
