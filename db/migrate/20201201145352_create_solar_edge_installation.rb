class CreateSolarEdgeInstallation < ActiveRecord::Migration[6.0]
  def change
    create_table :solar_edge_installations do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.references :amr_data_feed_config, null: false, foreign_key: { on_delete: :cascade }
      t.text       :site_id
      t.text       :api_key
      t.text       :mpan
      t.json       :information, default: {}
      t.timestamps
    end
  end
end
