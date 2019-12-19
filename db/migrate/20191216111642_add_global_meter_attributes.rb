class AddGlobalMeterAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :global_meter_attributes do |t|
      t.string :meter_type, null: false
      t.string :attribute_type, null: false
      t.json :input_data
      t.text :reason
      t.timestamps
      t.references :replaced_by, foreign_key: {on_delete: :nullify, to_table: :global_meter_attributes}
      t.references :deleted_by, foreign_key: {on_delete: :restrict, to_table: :users}
      t.references :created_by, foreign_key: {on_delete: :nullify, to_table: :users}
    end
  end
end
