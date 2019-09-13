class AddLowCarbonHubInstallation < ActiveRecord::Migration[6.0]
  def change
    create_table :low_carbon_hub_installations do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.integer    :rbee_meter_id
      t.json       :information, default: {}
      t.timestamps
    end
  end
end
