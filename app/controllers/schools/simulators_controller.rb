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
        @output = if params[:which] == '0'
                    [{ chart_type: chart_type, data: chart_manager.run_chart(CHART_CONFIG_FOR_SCHOOL, chart_type, true) }]
                  else
                    [{ chart_type: chart_type, data: chart_manager.run_chart(CHART_CONFIG_FOR_SIMULATOR, chart_type, true) }]
                  end

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
