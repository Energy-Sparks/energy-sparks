class AddDataSourceToMeters < ActiveRecord::Migration[6.0]
  def change
    add_reference :meters, :data_source, index: true
  end
end
