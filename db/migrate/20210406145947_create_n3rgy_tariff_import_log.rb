class CreateN3rgyTariffImportLog < ActiveRecord::Migration[6.0]
  def change
    create_table :n3rgy_tariff_import_logs do |t|
      t.text       :description
      t.text       :error_messages
      t.datetime   :import_time
      t.integer    :prices_imported, default: 0, null: false
      t.integer    :prices_updated, default: 0, null: false
      t.integer    :standing_charges_imported, default: 0, null: false
      t.integer    :standing_charges_updated, default: 0, null: false
      t.timestamps
    end
  end
end
