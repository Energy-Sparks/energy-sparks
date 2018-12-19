require 'dashboard'

class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :manage, Alert, school_id: @school.id
    if params[:gas_date_picker]
      @gas_date = Date.parse(params[:gas_date_picker])
    end

    if params[:electricity_date_picker]
      @electricity_date = Date.parse(params[:electricity_date_picker])
    end

    @results = AlertGeneratorService.new(@school).perform

    @latest_gas_reading = @school.last_reading_date(:gas)
    @latest_electricity_reading = @school.last_reading_date(:electricity)
    @earliest_gas_reading = @school.earliest_reading_date(:gas)
    @earliest_electricity_reading = @school.earliest_reading_date(:electricity)

    @gas_alerts_date = @gas_date || @latest_gas_reading
    @electricity_alerts_date = @electricity_date || @latest_electricity_reading

    @alert_fuel_dates = { 'gas' => @latest_gas_reading, 'electricity' => @latest_electricity_reading }
  end
end
