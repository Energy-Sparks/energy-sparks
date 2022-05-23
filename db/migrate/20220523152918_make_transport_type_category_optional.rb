class MakeTransportTypeCategoryOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null :transport_types, :category, true, 1
    change_column_default :transport_types, :category, from: 0, to: nil
  end
end
