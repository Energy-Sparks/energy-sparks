module Alerts
  module Adapters
    class Adapter
      def initialize(alert_type:, school:, analysis_date:, aggregate_school:)
        @alert_type = alert_type
        @school = school
        @analysis_date = analysis_date
        @aggregate_school = aggregate_school
      end

      def alert_class
        @alert_type.class_name.constantize
      end
    end
  end
end
