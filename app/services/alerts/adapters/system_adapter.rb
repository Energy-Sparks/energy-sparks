module Alerts
  module Adapters
    class SystemAdapter < Adapter
      def report
        alert_class.new(school: @school, alert_type: @alert_type, today: Time.zone.today).report
      end

      def content
        []
      end

      def benchmark_dates
        []
      end

      def has_structured_content?
        false
      end

      def structured_content
        []
      end
    end
  end
end
