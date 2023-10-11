class AddStartDatesAndEstimatesToConfiguration < ActiveRecord::Migration[6.0]
  def change
    # hash of fuel_type to estimate
    add_column :configurations, :estimated_consumption, :json, default: {}
    # hash of fuel_type to hash holding start and end dates
    add_column :configurations, :aggregate_meter_dates, :json, default: {}
  end
end
