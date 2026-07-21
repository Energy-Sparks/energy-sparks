# frozen_string_literal: true

class CreateMeterZInstallation < ActiveRecord::Migration[8.1]
  def change
    create_table :meter_z_installations do |t|
      t.text :api_key, null: false
      t.boolean :active, null: false, default: true
      t.jsonb :meters_list
      t.references :amr_data_feed_config, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
    add_index :meter_z_installations, :api_key, unique: true
    add_reference :meters, :meter_z_installation, foreign_key: { on_delete: :cascade }
    # create_table :meter_z_installation_schools do |t|
    #   t.references :school, null: false, foreign_key: true
    #   t.references :meter_z_installation, null: false, foreign_key: true
    #   t.timestamps
    # end
  end
end
