module Alerts
  module Adapters
    class SystemAdapter < Adapter
      def report
        alert_class.new(school: @school, alert_type: @alert_type, today: @analysis_date).report
      end

      def content
        []
      end

      def benchmark_dates
        []
      end
    end
  end
end
