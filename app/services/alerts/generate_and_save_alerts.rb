module Alerts
  class GenerateAndSaveAlerts
    def initialize(school, alert_framework_adapter = FrameworkAdapter)
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
      alert_types.map do |alert_type|
        begin
          alert = @alert_framework_adapter.new(alert_type, @school).analyse
          alert.save
        rescue => e
          Rails.logger.error "Exception: #{alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e)
        end
      end
    end
  end
end
