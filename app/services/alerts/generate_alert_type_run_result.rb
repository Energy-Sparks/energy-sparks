module Alerts
  class GenerateAlertTypeRunResult
    def initialize(
        school:,
        alert_type:,
        asof_date: nil,
        framework_adapter: FrameworkAdapter,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school
      )
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
      @alert_type = alert_type
      @asof_date = asof_date
    end

    def perform
      generate_alert_report
    end

    private

    def generate_alert_report
      alert_framework_adapter = @alert_framework_adapter_class.new(alert_type: @alert_type, school: @school, aggregate_school: @aggregate_school, analysis_date: @asof_date)
      @asof_date = alert_framework_adapter.analysis_date if @asof_date.nil?

      alert_type_run_result = AlertTypeRunResult.new(alert_type: @alert_type, asof_date: @asof_date)

      report = alert_framework_adapter.analyse

      alert_type_run_result.reports << report
      alert_type_run_result
    rescue => e
      error_message = "Exception: #{@alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, school_id: @school.id, school_name: @school.name, alert_type: @alert_type.class_name)

      error_message = "#{error_message}\n" + e.backtrace.join("\n")

      alert_type_run_result.error_messages << error_message
      alert_type_run_result
    end
  end
end
