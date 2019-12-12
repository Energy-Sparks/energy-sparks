class AddFurtherAttributeTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :school_meter_attributes do |t|
      t.references :school, foreign_key: {on_delete: :cascade}, null: false
      t.string :meter_type, null: false
      t.string :attribute_type, null: false
      t.json :input_data
      t.text :reason
      t.timestamps
    end
    create_table :school_group_meter_attributes do |t|
      t.references :school_group, foreign_key: {on_delete: :cascade}, null: false
      t.string :meter_type, null: false
      t.string :attribute_type, null: false
      t.json :input_data
      t.text :reason
      t.timestamps
    end
    add_column :meter_attributes, :reason, :text
  end
end
