module Alerts
  module Adapters
    class Report
      attr_reader :valid, :rating, :enough_data, :relevance, :template_data, :chart_data, :table_data, :priority_data, :benchmark_data, :asof_date
      def initialize(valid:, rating:, enough_data:, relevance:, template_data: {}, chart_data: {}, table_data: {}, priority_data: {}, benchmark_data: {})
        @valid = valid
        @rating = rating
        @enough_data = enough_data
        @relevance = relevance
        @template_data = template_data
        @chart_data = chart_data
        @table_data = table_data
        @priority_data = priority_data
        @benchmark_data = benchmark_data
      end

      def displayable?
        valid &&
          !enough_data.nil? &&
          !(enough_data == :not_enough) &&
          relevance == :relevant &&
          !rating.nil?
      end
    end
  end
end
