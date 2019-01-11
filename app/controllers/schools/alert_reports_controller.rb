class Schools::AlertReportsController < ApplicationController
  include SchoolAggregation

  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    set_up_reading_dates
    @results = AlertGeneratorService.new(@school, aggregate_school(@school), @gas_alerts_date, @electricity_alerts_date).perform
    @alert_fuel_dates = { 'gas' => @gas_alerts_date, 'electricity' => @electricity_alerts_date }
  end

private

  def set_up_reading_dates
    if params[:gas_date_picker]
      @gas_date = Date.parse(params[:gas_date_picker])
    end

    if params[:electricity_date_picker]
      @electricity_date = Date.parse(params[:electricity_date_picker])
    end

    @earliest_gas_reading = @school.earliest_reading_date(:gas)
    @latest_gas_reading = @school.last_reading_date(:gas)

    @latest_electricity_reading = @school.last_reading_date(:electricity)
    @earliest_electricity_reading = @school.earliest_reading_date(:electricity)

    @gas_alerts_date = @gas_date || @latest_gas_reading
    @electricity_alerts_date = @electricity_date || @latest_electricity_reading
  end
end
