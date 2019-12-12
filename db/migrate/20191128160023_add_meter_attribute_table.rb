class AddMeterAttributeTable < ActiveRecord::Migration[6.0]
  def change
    create_table :meter_attributes do |t|
      t.references :meter, foreign_key: {on_delete: :cascade}, null: false
      t.string :attribute_type, null: false
      t.json :input_data
      t.timestamps
    end
  end
end
