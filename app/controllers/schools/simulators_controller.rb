require 'dashboard'

class Schools::SimulatorsController < ApplicationController
  before_action :authorise_school

  def index
  end

  def show
  end

  def new
    @simulator_configuration = ElectricitySimulatorConfiguration.new
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


    # intraday_line_school_days_6months:  {
    #   name:             'Intraday (Comparison 6 months apart)',
    #   chart1_type:      :line,
    #   series_breakdown: :none,
    #   timescale:        [{ schoolweek: 0 }, { schoolweek: -20 }],
    #   x_axis:           :intraday,
    #   meter_definition: :allelectricity,
    #   filter:            { daytype: :occupied },
    #   yaxis_units:      :kw,
    #   yaxis_scaling:    :none
    # },

   # electricity_simulator