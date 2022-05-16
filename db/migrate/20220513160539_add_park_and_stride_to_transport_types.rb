class AddParkAndStrideToTransportTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :transport_types, :park_and_stride, :boolean, { default: false, null: false }
  end
end
