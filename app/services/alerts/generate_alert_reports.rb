module Alerts
  class GenerateAlertReports
    def initialize(
        school:,
        framework_adapter: FrameworkAdapter,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school
      )
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
    end

    def perform
      alert_type_run_results = []

      relevant_alert_types.each do |alert_type|
        alert_type_run_result = AlertTypeRunResult.new(alert_type: alert_type)
        alert_type_run_results << generate_alert_report(alert_type, alert_type_run_result)
      end

      alert_type_run_results
    end

    private

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list
    end

    def generate_alert_report(alert_type, alert_type_run_result)
      alert_framework_adapter = @alert_framework_adapter_class.new(alert_type: alert_type, school: @school, aggregate_school: @aggregate_school)
      asof_date = alert_framework_adapter.analysis_date

      report = alert_framework_adapter.analyse
      alert_type_run_result.reports << report
      alert_type_run_result
    rescue => e
      error_message = "Exception: #{alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, school_id: @school.id, school_name: @school.name, alert_type: alert_type.class_name)

      error_message = "#{error_message}\n" + e.backtrace.join("\n")
      error_attributes = ErrorAttributesFactory.new(alert_type, asof_date, error_message).generate

      alert_type_run_result.error_attributes << error_attributes
      alert_type_run_result
    end
  end
end
