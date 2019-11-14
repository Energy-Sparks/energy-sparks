module Alerts
  class AlertTypeRunResult
    attr_accessor :alert_type, :reports, :error_messages, :asof_date

    def initialize(alert_type:, reports: [], error_messages: [], asof_date:)
      @alert_type = alert_type
      @reports = reports
      @error_messages = error_messages
      @asof_date = asof_date
    end
  end
end
