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
