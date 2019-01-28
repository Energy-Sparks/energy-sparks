class Schools::AlertReportsController < ApplicationController
  include SchoolAggregation

  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType
    @alerts = @school.alerts.order(created_at: :desc).group_by { |a| [a.alert_type_id] }.values.map { |b| b.first }
   # @alerts = @school.alerts.includes(:alert_type).order(:run_on).select('alert_type_id, run_on, alert_types.fuel_type').group('run_on, alert_type_id, alert_types.fuel_type')

    set_up_gas_reading_dates if @school.meters?(:gas)
    set_up_electricity_reading_dates if @school.meters?(:electricity)

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
