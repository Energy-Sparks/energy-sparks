module Alerts
  class ErrorAttributesFactory
    def initialize(alert_type, asof_date, information, alert_generation_run = nil)
      @alert_type = alert_type
      @asof_date = asof_date
      @information = information
      @alert_generation_run_id = alert_generation_run.nil? ? nil : alert_generation_run.id
    end

    def generate
      {
        asof_date: @asof_date,
        alert_type_id: @alert_type.id,
        information: @information,
        alert_generation_run_id: @alert_generation_run_id,
      }
    end
  end
end
