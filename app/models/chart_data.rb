class ChartData
  def initialize(aggregated_school, chart_type, show_benchmark_figures, y_axis_units = :kwh)
    @aggregated_school = aggregated_school
    @chart_type = chart_type
    @y_axis_units = y_axis_units
    @show_benchmark_figures = show_benchmark_figures
  end

  def data
    chart_manager = ChartManager.new(@aggregated_school, @show_benchmark_figures)
    chart_config = customised_chart_config(chart_manager)

    [chart_manager.run_chart(chart_config, @chart_type)]
  end

  class Values
    attr_reader :anaylsis_type, :title, :chart1_type, :chart1_subtype, :y_axis_label, :x_axis_categories, :advice_header, :advice_footer, :y2_axis_label, :series_data, :x_axis_ranges

    def initialize(chart)
      @title = chart[:title]
      @x_axis_categories = chart[:x_axis]
      @x_axis_ranges = chart[:x_axis_ranges] # Not actually used but range of actual dates
      @chart1_type    = chart[:chart1_type]
      @chart1_subtype = chart[:chart1_subtype]
      @y_axis_label   = chart[:y_axis_label]
      @x_axis_categories = chart[:x_axis]
      @configuration = chart[:configuration]
      @advice_header = chart[:advice_header]
      @advice_footer = chart[:advice_footer]

      @y2_axis_label = '?'
      @series_data   = '?' # series array
    end
  end

private

  def customised_chart_config(chart_manager)
    chart_config = chart_manager.resolve_chart_inheritance(ChartManager::STANDARD_CHART_CONFIGURATION[@chart_type])
    if chart_config.key?(:yaxis_units) && chart_config[:yaxis_units] == :kwh
      chart_config[:yaxis_units] = @y_axis_units
      chart_config[:yaxis_units] = :£ if @y_axis_units == :gb_pounds
    end
    chart_config
  end
end

# {:title=>"Breakdown by type of day/time: Electricity 18,464 kWh",
#  :x_axis=>["No Dates"],
#  :x_axis_ranges=>[[Mon, 11 Dec 2017, Sun, 09 Dec 2018]],
#  :x_data=>
#   {"Holiday"=>[2444.9270000000015],
#    "Weekend"=>[2380.080999999999],
#    "School Day Open"=>[9527.59599999999],
#    "School Day Closed"=>[4111.204999999987]},
#  :chart1_type=>:pie,
#  :chart1_subtype=>nil,
#  :y_axis_label=>"kWh",
#  :config_name=>:daytype_breakdown_electricity,
#  :configuration=>
#   {:name=>"Breakdown by type of day/time: Electricity",
#    :chart1_type=>:pie,
#    :meter_definition=>:allelectricity,
#    :x_axis=>:nodatebuckets,
#    :series_breakdown=>:daytype,
#    :yaxis_units=>:kwh,
#    :yaxis_scaling=>:none,
#    :timescale=>:year,
#    :min_combined_school_date=>Thu, 17 Jun 2010,
#    :max_combined_school_date=>Sun, 09 Dec 2018,
#    :y_axis_label=>"kWh"},
#  :advice_header=>
#  :advice_footer=>
