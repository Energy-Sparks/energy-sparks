class AddLowCarbonHubInstallation < ActiveRecord::Migration[6.0]
  def change
    create_table :low_carbon_hub_installations do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.references :amr_data_feed_config, null: false, foreign_key: { on_delete: :cascade }
      t.text       :rbee_meter_id
      t.json       :information, default: {}
      t.timestamps
    end
  end
end
