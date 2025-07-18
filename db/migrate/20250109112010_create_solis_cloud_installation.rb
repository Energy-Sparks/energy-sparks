class CreateSolisCloudInstallation < ActiveRecord::Migration[7.1]
  def change
    create_table :solis_cloud_installations do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.references :amr_data_feed_config, null: false, foreign_key: { on_delete: :cascade }
      t.text       :api_id
      t.text       :api_secret
      t.jsonb      :station_list, default: {}
      t.timestamps
    end
    add_reference :meters, :solis_cloud_installation, foreign_key: { on_delete: :cascade }
  end
end
