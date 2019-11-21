module Alerts
  module Adapters
    class Adapter
      def initialize(alert_type:, school:, analysis_date:, aggregate_school:, use_max_meter_date_if_less_than_asof_date: false)
        @alert_type = alert_type
        @school = school
        @analysis_date = analysis_date
        @aggregate_school = aggregate_school
        @use_max_meter_date_if_less_than_asof_date = use_max_meter_date_if_less_than_asof_date
      end

      def alert_class
        @alert_type.class_name.constantize
      end
    end
  end
end
