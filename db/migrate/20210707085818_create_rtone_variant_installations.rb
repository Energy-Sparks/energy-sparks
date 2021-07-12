class CreateRtoneVariantInstallations < ActiveRecord::Migration[6.0]
  def change
    create_table :rtone_variant_installations do |t|
      t.string :username, null: false
      t.string :password, null: false
      t.string :rtone_meter_id, null: false
      t.integer :rtone_component_type, null: false
      t.json   :configuration
      t.references :school, null: false, foreign_key: true
      t.references :amr_data_feed_config, null: false, foreign_key: true
      t.references :meter, null: false, foreign_key: true
      t.timestamps
    end
  end
end
