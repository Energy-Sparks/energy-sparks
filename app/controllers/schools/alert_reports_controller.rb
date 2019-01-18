class Schools::AlertReportsController < ApplicationController
  include SchoolAggregation

  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    set_up_gas_reading_dates if @school.meters?(:gas)
    set_up_electricity_reading_dates if @school.meters?(:electricity)

    @results = Alerts::GeneratorService.new(@school, aggregate_school(@school), @gas_alerts_date, @electricity_alerts_date).perform
    @alert_fuel_dates = { 'gas' => @gas_alerts_date, 'electricity' => @electricity_alerts_date }
  end

private

  def set_up_gas_reading_dates
    if params[:gas_date_picker]
      @gas_date = Date.parse(params[:gas_date_picker])
    end

    @earliest_gas_reading = @school.earliest_reading_date(:gas)
    @latest_gas_reading = @school.last_common_reading_date_for_active_meters_of_supply(:gas)
    @gas_alerts_date = @gas_date || @latest_gas_reading
  end

  def set_up_electricity_reading_dates
    if params[:electricity_date_picker]
      @electricity_date = Date.parse(params[:electricity_date_picker])
    end

    @latest_electricity_reading = @school.last_common_reading_date_for_active_meters_of_supply(:electricity)
    @earliest_electricity_reading = @school.earliest_reading_date(:electricity)
    @electricity_alerts_date = @electricity_date || @latest_electricity_reading
  end
end
