require 'dashboard'

class Schools::SimulationsController < ApplicationController
  before_action :authorise_school
  before_action :set_simulation, only: [:show, :edit, :destroy, :update]

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
    @simulations = Simulation.where(school: @school)
    create if @simulations.empty?
  end

  def show
    @simulation_configuration = @simulation.configuration
    local_school = aggregate_school

    simulator = ElectricitySimulator.new(local_school)

    simulator.simulate(@simulation_configuration)
    chart_manager = ChartManager.new(local_school)

    @charts = [:electricity_simulator_pie, :intraday_line_school_days_6months_simulator_submeters, :group_by_week_electricity_simulator_appliance]
    @number_of_charts = @charts.size

    respond_to do |format|
      format.html do
        render :show
      end
      format.json do
        if params[:chart_type]
          chart_type = params[:chart_type]
          chart_type = chart_type.to_sym if chart_type.instance_of? String
          @charts = [chart_type]
        end

        @output = @charts.map do |this_chart_type|
          { chart_type: this_chart_type, data: chart_manager.run_standard_chart(this_chart_type) }
        end
        render 'schools/analysis/chart_data'
      end
    end
  end

  def create
    simulation_configuration = ElectricitySimulatorConfiguration.new

    # If we have parameters, use them, else create using the defaults
    if params[:simulation]
      updated_simulation_configuration = simulation_params.to_h.symbolize_keys
      updated_simulation_configuration.each do |key, value|
        simulation_configuration.each do |_k, v|
          if v.key?(key)
            v[key] = convert_to_correct_format(key, value)
            break
          end
        end
      end
      default = false
      title = simulation_params[:title]
      notes = simulation_params[:notes]
    else
      default = true
      title = "Default appliance configuration"
      notes = "This simulation has been run with the default appliance configurations, you can create a new simulation with your own configurations."
    end
    @simulation = Simulation.create(user: current_user, school: @school, configuration: simulation_configuration, default: default, title: title, notes: notes)

    redirect_to school_simulation_path(@school, @simulation)
  end

  def destroy
    @simulation.delete
    respond_to do |format|
      format.html { redirect_to school_simulations_path(@school), notice: 'Simulation was deleted.' }
      format.json { head :no_content }
    end
  end

  def update
    simulation_configuration = @simulation.configuration

    updated_simulation_configuration = simulation_params.to_h.symbolize_keys

    updated_simulation_configuration.each do |key, value|
      simulation_configuration.each do |_k, v|
        if v.key?(key) && key != :title
          v[key] = convert_to_correct_format(key, value)
          break
        end
      end
    end

    if @simulation.update(configuration: simulation_configuration, title: simulation_params[:title], notes: simulation_params[:notes])
      redirect_to school_simulation_path(@school, @simulation)
    else
      render :edit
    end
  end

  def new
    @simulation = Simulation.new
    @local_school = aggregate_school
    @actual_simulator = ElectricitySimulator.new(@local_school)
    @simulation_configuration = @actual_simulator.default_simulator_parameters
    sort_out_simulation_stuff
  end

  def edit
    @local_school = aggregate_school
    @actual_simulator = ElectricitySimulator.new(@local_school)
    @simulation_configuration = @simulation.configuration
    sort_out_simulation_stuff
  end

private

  def set_simulation
    @simulation = Simulation.find(params[:id])
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

  def sort_out_simulation_stuff
    if params.key?(:simulation)
      updated_simulation_configuration = simulation_params.to_h.symbolize_keys

      updated_simulation_configuration.each do |key, value|
        @simulation_configuration.each do |_k, v|
          if v.key?(key)
            v[key] = convert_to_correct_format(key, value)
            break
          end
        end
      end
    end

    @actual_simulator.simulate(@simulation_configuration)
    @charts = [:intraday_line_school_days_6months, :intraday_line_school_days_6months]
    chart_type = :intraday_line_school_days_6months

    @number_of_charts = @charts.size

    respond_to do |format|
      format.html
      format.json do
        chart_manager = ChartManager.new(@local_school)
        winter_config_for_school = chart_config_for_school.deep_dup
        winter_config_for_school[:timescale] = [{ schoolweek: -20 }]
        winter_config_for_simulator = chart_config_for_simulator.deep_dup
        winter_config_for_simulator[:timescale] = [{ schoolweek: -20 }]

        @output = [
          { chart_type: chart_type, data: sort_out_chart_data(chart_manager, chart_type, chart_config_for_school, chart_config_for_simulator) },
          { chart_type: chart_type, data: sort_out_chart_data(chart_manager, chart_type, winter_config_for_school, winter_config_for_simulator) },
        ]
        render 'schools/analysis/chart_data'
      end
    end
  end

  def sort_out_chart_data(chart_manager, chart_type, chart_config_for_school, chart_config_for_simulator)
    school_chart_info = chart_manager.run_chart(chart_config_for_school, chart_type)
    simulator_chart_info = chart_manager.run_chart(chart_config_for_simulator, chart_type)

    school_data = school_chart_info[:x_data]
    simulator_data = simulator_chart_info[:x_data]

    school_values = school_data[school_data.keys.first]
    simulator_values = simulator_data[simulator_data.keys.first]

    school_chart_info[:x_data] = { 'Actual school energy usage' => school_values, 'Simulated energy usage' => simulator_values }
    school_chart_info
  end

  def is_float?(string)
    true if Float(string) rescue false
  end

  def is_integer?(string)
    true if Integer(string) rescue false
  end

  def convert_to_correct_format(key, value)
    return value if key == :title
    return value.to_time.utc if key.to_s.include?('time')
    return value.to_f if is_float?(value)
    is_integer?(value) ? value.to_i : value
  end

  def simulation_params
    editable = ElectricitySimulatorConfiguration.new.map { |_key, value| value[:editable] }.compact.flatten
    editable.push(:title)
    editable.push(:notes)
    params.require(:simulation).permit(editable)
  end

  def chart_config_for_school
    CHART_CONFIG_FOR_SCHOOL.deep_dup
  end

  def chart_config_for_simulator
    CHART_CONFIG_FOR_SIMULATOR.deep_dup
  end
end
