module Alerts
  module Adapters
    class Report
      attr_reader :status, :detail, :summary, :help_url, :rating, :template_data, :chart_data, :table_data
      def initialize(status:, summary:, rating:, detail: [], help_url: nil, template_data: {}, chart_data: {}, table_data: {})
        @status = status
        @detail = detail
        @summary = summary
        @help_url = help_url
        @rating = rating
        @template_data = template_data
        @chart_data = chart_data
        @table_data = table_data
      end
    end
  end
end
