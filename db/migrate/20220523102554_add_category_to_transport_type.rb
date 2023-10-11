class AddCategoryToTransportType < ActiveRecord::Migration[6.0]
  def change
    add_column :transport_types, :category, :integer, null: false, default: 0
  end
end
