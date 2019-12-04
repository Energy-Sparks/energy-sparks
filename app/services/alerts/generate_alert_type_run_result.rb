module Alerts
  class GenerateAlertTypeRunResult
    def initialize(
        school:,
        alert_type:,
        framework_adapter: FrameworkAdapter,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school,
        use_max_meter_date_if_less_than_asof_date: false
      )
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
      @alert_type = alert_type
      @use_max_meter_date_if_less_than_asof_date = use_max_meter_date_if_less_than_asof_date
    end

    def perform(asof_date = nil)
      generate_alert_report(asof_date)
    end

    def benchmark_dates(asof_date)
      alert_framework_adapter(asof_date).benchmark_dates
    end

    private

    def alert_framework_adapter(asof_date)
      @alert_framework_adapter_class.new(alert_type: @alert_type, school: @school, aggregate_school: @aggregate_school, analysis_date: asof_date, use_max_meter_date_if_less_than_asof_date: @use_max_meter_date_if_less_than_asof_date)
    end

    def generate_alert_report(asof_date)
      afa = alert_framework_adapter(asof_date)
      alert_type_run_result = AlertTypeRunResult.new(alert_type: @alert_type, asof_date: afa.analysis_date)

      report = afa.analyse

      alert_type_run_result.reports << report
      alert_type_run_result
      # rubocop:disable Lint/RescueException
    rescue Exception => e
      # rubocop:enable Lint/RescueException
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
