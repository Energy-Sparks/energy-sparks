class AddDccAttributesToMeter < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :dcc_meter, :boolean, default: false
    add_column :meters, :consent_granted, :boolean, default: false
  end
end
