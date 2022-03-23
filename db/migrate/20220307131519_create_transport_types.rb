class CreateTransportTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :transport_types do |t|
      t.string :name, null: false
      t.string :image, null: false
      t.decimal :kg_co2e_per_km, null: false, default: 0.0
      t.decimal :speed_km_per_hour, null: false, default: 0.0
      t.string :note
      t.boolean :can_share, null: false, default: false
      t.timestamps
    end
  end
end
