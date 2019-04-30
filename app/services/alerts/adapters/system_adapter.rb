module Alerts
  module Adapters
    class SystemAdapter < Adapter
      def report
        alert_class.new(school: @school).report
      end
    end
  end
end
