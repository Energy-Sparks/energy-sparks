class CreateCads < ActiveRecord::Migration[6.0]
  def change
    create_table :cads do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.string :name, null: false
      t.string :device_identifier, null: false
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
