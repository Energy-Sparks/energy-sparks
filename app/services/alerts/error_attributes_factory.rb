module Alerts
  class ErrorAttributesFactory
    def initialize(alert_type, asof_date, information, alert_generation_run)
      @alert_type = alert_type
      @asof_date = asof_date
      @information = information
      @alert_generation_run = alert_generation_run
    end

    def generate
      now = Time.zone.now

      {
        asof_date: @asof_date,
        alert_type_id: @alert_type.id,
        information: @information,
        alert_generation_run_id: @alert_generation_run.id,
        created_at: now,
        updated_at: now
      }
    end
  end
end
