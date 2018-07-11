require 'dashboard'

class Schools::SimulatorsController < ApplicationController
  before_action :authorise_school

  CHART_CONFIG_FOR_SCHOOL = {
    name:             'Intraday (Comparison 6 months apart)',
    chart1_type:      :line,
    series_breakdown: :none,
    timescale:        [{ schoolweek: 0 }],
    x_axis:           :intraday,
    meter_definition: :allelectricity,
    filter:            { daytype: :occupied },
    yaxis_units:      :kw,
    yaxis_scaling:    :none
  }.freeze

  CHART_CONFIG_FOR_SIMULATOR = {
    name:             'Intraday (Comparison 6 months apart)',
    chart1_type:      :line,
    series_breakdown: :none,
    timescale:        [{ schoolweek: 0 }],
    x_axis:           :intraday,
    meter_definition: :electricity_simulator,
    filter:            { daytype: :occupied },
    yaxis_units:      :kw,
    yaxis_scaling:    :none
  }.freeze

  def index
  end

  def show
  end

  def create
    simulator_configuration = ElectricitySimulatorConfiguration.new
    updated_simulator_configuration = simulator_params.to_h.symbolize_keys

    updated_simulator_configuration.each do |key, value|
      simulator_configuration.each do |_k, v|
        if v.key?(key)
          v[key] = convert_to_correct_format(value)
          break
        end
      end
    end

    respond_to do |format|
      format.json do
        local_school = aggregate_school

        simulator = ElectricitySimulator.new(local_school)

        simulator.simulate(simulator_configuration)
        chart_manager = ChartManager.new(local_school)
        @output = [{ chart_type: :intraday_line_school_days_6months, data: chart_manager.run_chart(CHART_CONFIG_FOR_SIMULATOR, :intraday_line_school_days_6months, true) }]
        render 'schools/chart_data/chart_data'
      end
    end
  end

  def is_float?(string)
    true if Float(string) rescue false
  end

  def is_integer?(string)
    true if Integer(string) rescue false
  end

  def convert_to_correct_format(value)
    value = is_float?(value) ? value.to_f : value
    is_integer?(value) ? value.to_i : value
  end

  def simulator_params
    editable = ElectricitySimulatorConfiguration.new.map { |_key, value| value[:editable] }.compact.flatten
    params.require(:simulator).permit(editable)
  end

  def chart_config_for_school
    CHART_CONFIG_FOR_SCHOOL.deep_dup
  end

  def chart_config_for_simulator
    CHART_CONFIG_FOR_SIMULATOR.deep_dup
  end

  def new
    @simulator = Simulator.new

    local_school = aggregate_school
    @actual_simulator = ElectricitySimulator.new(local_school)
    @simulator_configuration = @actual_simulator.default_simulator_parameters
    @actual_simulator.simulate(@simulator_configuration)

    @charts = [:intraday_line_school_days_6months, :intraday_line_school_days_6months]

    chart_type = :intraday_line_school_days_6months

    @number_of_charts = @charts.size

    respond_to do |format|
      format.html
      format.json do
        chart_manager = ChartManager.new(local_school)

        @school_chart_info = chart_manager.run_chart(chart_config_for_school, chart_type, true)
        @simulator_chart_info = chart_manager.run_chart(chart_config_for_simulator, chart_type, true)

        @school_data = @school_chart_info[:x_data]
        @simulator_data = @simulator_chart_info[:x_data]

        @school_values = @school_chart_info[:x_data][@school_chart_info[:x_data].keys.first]
        @simulator_values = @simulator_chart_info[:x_data][@simulator_chart_info[:x_data].keys.first]

        @school_chart_info[:x_data] = { 'School Energy' => @school_values, 'Simulator Energy' => @simulator_values }

        @output = [{ chart_type: chart_type, data: @school_chart_info }]
        render 'schools/chart_data/chart_data'
      end
    end
  end

  def edit
  end

  def authorise_school
    @school = School.find_by_slug(params[:school_id])
    authorize! :show, @school
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = MeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end
