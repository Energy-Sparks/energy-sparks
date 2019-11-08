module Alerts
  class GenerateAndSaveAlerts
    def initialize(school, alert_framework_adapter = FrameworkAdapter)
      @school = school
      @alert_framework_adapter = alert_framework_adapter
    end

    def perform
      generate(AlertType.no_fuel)

      if @school.has_electricity?
        generate(AlertType.electricity)
      end

      if @school.has_gas?
        generate(AlertType.gas)
      end

      if @school.has_storage_heaters?
        generate(AlertType.storage_heater)
      end

      if @school.has_solar_pv?
        generate(AlertType.solar_pv)
      end
    end

  private

    def generate(alert_types)
      alert_types.map do |alert_type|
        begin
          alert = @alert_framework_adapter.new(alert_type, @school).analyse
          alert.save!
        rescue => e
          Rails.logger.error "Exception: #{alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          Rollbar.error(e, school_id: @school.id, school_name: @school.name, alert_type: alert_type.class_name)
        end
      end
    end
  end
end
