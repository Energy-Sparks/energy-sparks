class AddActiveToMeter < ActiveRecord::Migration[5.0]
  def change
    add_column :meters, :active, :boolean, default: true, index: true
  end
end
