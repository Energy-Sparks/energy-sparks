class AllowNullTransportTypeName < ActiveRecord::Migration[6.0]
  def change
    change_column_null :transport_types, :name, true
  end
end
