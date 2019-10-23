class AddEquivalenceTypesAndContent < ActiveRecord::Migration[6.0]
  def change

    create_table :equivalence_types do |t|
      t.integer :meter_type, null: false
      t.integer :time_period, null: false
      t.timestamps
    end

    create_table :equivalence_type_content_versions do |t|
      t.text :equivalence, null: false
      t.references :equivalence_type, null: false, foreign_key: {on_delete: :cascade}
      t.references :replaced_by,  foreign_key: {on_delete: :nullify, to_table: :equivalence_type_content_versions}, index: {name: 'eqtcv_eqtcv_repl'}
      t.timestamps
    end

    create_table :equivalences do |t|
      t.references :equivalence_type_content_version, null: false, foreign_key: {on_delete: :cascade}
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.json :data, default: {}
      t.timestamps
    end

  end
end
