class CreateTariffImportLog < ActiveRecord::Migration[6.0]
  def change
    create_table :tariff_import_logs do |t|
      t.text       :source, null: false
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
