module Alerts
  module Adapters
    class Report
      attr_reader :valid, :rating, :enough_data, :relevance, :template_data, :template_data_cy, :chart_data, :table_data, :priority_data, :benchmark_data, :benchmark_data_cy, :asof_date, :analysis_object
      def initialize(valid:, rating:, enough_data:, relevance:, template_data: {}, template_data_cy: {}, chart_data: {}, table_data: {}, priority_data: {}, benchmark_data: {}, benchmark_data_cy: {}, analysis_object: nil)
        @valid = valid
        @rating = rating
        @enough_data = enough_data
        @relevance = relevance
        @template_data = template_data
        @template_data_cy = template_data_cy
        @chart_data = chart_data
        @table_data = table_data
        @priority_data = priority_data
        @benchmark_data = benchmark_data
        @benchmark_data_cy = benchmark_data_cy
        @analysis_object = analysis_object
      end

      def displayable?
        valid &&
          enough_data == :enough &&
          relevance == :relevant &&
          !rating.nil?
      end
    end
  end
end
