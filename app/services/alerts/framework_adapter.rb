module Alerts
  class FrameworkAdapter
    def initialize(alert_type, aggregate_school)
      @alert_type = alert_type
      @aggregate_school = aggregate_school
    end

    def alert_instance
      @alert_type.class_name.constantize.new(@aggregate_school)
    end
  end
end
