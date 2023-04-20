class AddProcurementRouteIdToMeter < ActiveRecord::Migration[6.0]
  def change
    add_reference :meters, :procurement_route, index: true
  end
end
