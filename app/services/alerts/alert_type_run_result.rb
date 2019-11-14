module Alerts
  class AlertTypeRunResult
    attr_accessor :alert_type, :reports, :error_attributes

    def initialize(alert_type:, reports: [], error_attributes: [])
      @alert_type = alert_type
      @reports = reports
      @error_attributes = error_attributes
    end
  end
end
