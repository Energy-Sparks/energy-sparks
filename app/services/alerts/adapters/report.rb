module Alerts
  module Adapters
    class Report
      attr_reader :status, :rating, :template_data, :chart_data, :table_data
      def initialize(status:, rating:, template_data: {}, chart_data: {}, table_data: {})
        @status = status
        @rating = rating
        @template_data = template_data
        @chart_data = chart_data
        @table_data = table_data
      end
    end
  end
end
