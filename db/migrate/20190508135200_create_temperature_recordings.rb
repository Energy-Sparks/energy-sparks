class CreateTemperatureRecordings < ActiveRecord::Migration[6.0]
  def change
    create_table :temperature_recordings do |t|
      t.references :observation, null: false, foreign_key: { on_delete: :cascade }
      t.references :location, null: false, foreign_key: { on_delete: :cascade }
      t.decimal    :centigrade,  null: false
      t.timestamps
    end
  end
end
