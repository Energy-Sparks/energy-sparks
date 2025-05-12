class AggregatorBase
  include Logging

  attr_reader :results, :chart_config, :school

  def initialize(school, chart_config, results)
    @school       = school
    @chart_config = AggregatorConfig.new(chart_config)
    @results      = results
  end
end
