class AddUniqueToTransportTypeName < ActiveRecord::Migration[6.0]
  def change
    add_index :transport_types, :name, unique: true
  end
end
