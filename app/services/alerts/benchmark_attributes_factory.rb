module Alerts
  class BenchmarkAttributesFactory
    def initialize(alert_report, alert_generation_run_id)
      @alert_report = alert_report
      @alert_generation_run_id = alert_generation_run_id
    end

    def generate
      now = Time.zone.now
      {
        alert_generation_run_id:  @alert_generation_run_id,
        alert_type_id:            @alert_report.alert_type.id,
        asof:                     @alert_report.asof_date,
        data:                     @alert_report.benchmark_data,
        created_at:               now,
        updated_at:               now
      }
    end
  end
end
