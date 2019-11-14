module Alerts
  class AlertAttributesFactory
    def initialize(school, alert_report, alert_generation_run, alert_type)
      @school = school
      @alert_report = alert_report
      @alert_generation_run = alert_generation_run
      @alert_type = alert_type
    end

    def generate
      now = Time.zone.now

      {
        school_id:                @school.id,
        alert_generation_run_id:  @alert_generation_run.id,
        alert_type_id:            @alert_type.id,
        run_on:                   @alert_report.asof_date,
        displayable:              @alert_report.displayable?,
        analytics_valid:          @alert_report.valid,
        rating:                   @alert_report.rating,
        enough_data:              @alert_report.enough_data,
        relevance:                @alert_report.relevance,
        template_data:            @alert_report.template_data,
        chart_data:               @alert_report.chart_data,
        table_data:               @alert_report.table_data,
        priority_data:            @alert_report.priority_data,
        created_at:               now,
        updated_at:               now
      }
    end
  end
end
