module Alerts
  class AlertTypeRunResult
    attr_accessor :alert_type, :reports, :error_messages, :asof_date

    def initialize(alert_type:, asof_date:, reports: [], error_messages: [])
      @alert_type = alert_type
      @reports = reports
      @error_messages = error_messages
      @asof_date = asof_date
    end

    def self.generate_alert_report(alert_type, asof_date, school)
      report = yield
      alert_type_run_result = self.class.new(alert_type: alert_type, asof_date: asof_date)
      alert_type_run_result.reports << report
      alert_type_run_result
    rescue StandardError => e
      error_message = "Exception: #{alert_type.class_name} for #{school.name}: #{e.class} #{e.message}"
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :generate_alert_report, school_id: school.id, school: school.name,
                       alert_type: alert_type.class_name)

      error_message = "#{error_message}\n" + e.backtrace.join("\n")

      alert_type_run_result.error_messages << error_message
      alert_type_run_result
    end
  end
end
