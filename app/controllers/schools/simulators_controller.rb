require 'dashboard'

class Schools::SimulatorsController < ApplicationController
  before_action :authorise_school

  def index
  end

  def show
  end

  def new
    @simulator_configuration = ElectricitySimulatorConfiguration.new
    @charts = [:intraday_line_school_days_6months, :intraday_line_school_days_6months]

        chart_type = :intraday_line_school_days_6months

        chart_config = {
          name:             'Intraday (Comparison 6 months apart)',
          chart1_type:      :line,
          series_breakdown: :none,
          timescale:        [{ schoolweek: 0 }],
          x_axis:           :intraday,
          meter_definition: :allelectricity,
          filter:            { daytype: :occupied },
          yaxis_units:      :kw,
          yaxis_scaling:    :none
        }

        chart_config_2 = {
          name:             'Intraday (Comparison 6 months apart)',
          chart1_type:      :line,
          series_breakdown: :none,
          timescale:        [{ schoolweek: 0 }],
          x_axis:           :intraday,
          meter_definition: :electricity_simulator,
          filter:            { daytype: :occupied },
          yaxis_units:      :kw,
          yaxis_scaling:    :none
        }

    @number_of_charts = @charts.size

    respond_to do |format|
      format.html
      format.json do

        local_school = aggregate_school

        simulator = ElectricitySimulator.new(local_school)
        pp simulator.default_simulator_parameters

        simulator.simulate(simulator.default_simulator_parameters)

        chart_manager = ChartManager.new(local_school)

        if params[:which] == '0'
        @output = [
          { chart_type: chart_type, data: chart_manager.run_chart(chart_config, chart_type, true) },
        ]
        else
        @output = [
          { chart_type: chart_type, data: chart_manager.run_chart(chart_config_2, chart_type, true) },
        ]
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


