class CreateRtoneVariantInstallations < ActiveRecord::Migration[6.0]
  def change
    create_table :rtone_variant_installations do |t|
      t.string :username
      t.string :password
      t.string :rtone_meter_id
      t.integer :rtone_meter_type
      t.references :school, null: false, foreign_key: true
      t.references :amr_data_feed_config, null: false, foreign_key: true
      t.references :meter, null: false, foreign_key: true
      t.timestamps
    end
  end
end
