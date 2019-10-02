class AddPseudoMeterToMeter < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :pseudo, :boolean, default: false
  end
end
