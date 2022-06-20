class AddPositionToTransportTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :transport_types, :position, :integer, null: false, default: 0
  end
end
