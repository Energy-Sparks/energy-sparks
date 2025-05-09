# frozen_string_literal: true

require_relative '../aggregator_config.rb'

module Charts
  # The chart aggregation framework uses filters in two ways:
  #
  # - during the process of calculating the series to filter out individual dates based on the chart configuration
  #   this avoids doing unnecessary calculations.
  # - after calculating the results to prune out individual series that aren't required for display
  #
  # The former filters can improve performance, but the latter can sometimes be simpler to implement.
  #
  # This modules provides the default implementation of the two types of filter.
  module Filters
    class Base
      include Logging

      def initialize(school, chart_config, results)
        @school       = school
        @chart_config = AggregatorConfig.new(chart_config)
        @results      = results
      end
    end
  end
end
