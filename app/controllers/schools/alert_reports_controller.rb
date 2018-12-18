require 'dashboard'

class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :manage, Alert, school_id: @school.id
    @results = AlertGeneratorService.new(@school).perform

    @latest_gas_reading = @school.last_reading_date(:gas)
    @latest_electricity_reading = @school.last_reading_date(:electricity)

    @alert_fuel_dates = { 'gas' => @latest_gas_reading, 'electricity' => @latest_electricity_reading }
  end
end
