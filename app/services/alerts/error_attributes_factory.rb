module Alerts
  class ErrorAttributesFactory
    def initialize(alert_type, asof_date, information, alert_generation_run_id)
      @alert_type = alert_type
      @asof_date = asof_date
      @information = information
      @alert_generation_run_id = alert_generation_run_id
    end

    def generate
      now = Time.zone.now

      {
        alert_generation_run_id: @alert_generation_run_id,
        asof_date: @asof_date,
        alert_type_id: @alert_type.id,
        information: @information,
        created_at: now,
        updated_at: now
      }
    end
  end
end
