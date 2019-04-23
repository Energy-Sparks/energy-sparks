class AlertCopyEditingMigrations < ActiveRecord::Migration[5.2]
  def change

    create_table :find_out_more_types do |t|
      t.references :alert_type, null: false, foreign_key: {on_delete: :restrict}
      t.decimal :rating_from, null: false
      t.decimal :rating_to, null: false
      t.string :description, null: false
      t.timestamps
    end

    create_table :find_out_more_type_content_versions do |t|
      t.references :find_out_more_type, null: false, foreign_key: {on_delete: :cascade}, index: {name: 'fom_content_v_fom_id'}
      t.string :dashboard_title, null: false
      t.string :page_title, null: false
      t.text :page_content, null: false
      t.integer :replaced_by_id
      t.timestamps
    end

    create_table :find_out_more_calculations do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.timestamps
    end

    create_table :find_out_mores do |t|
      t.references :find_out_more_type_content_version, null: false, foreign_key: {on_delete: :cascade}, index: {name: 'fom_fom_content_v_id'}
      t.references :alert, null: false, foreign_key: {on_delete: :cascade}
      t.references :find_out_more_calculation, null: false, foreign_key: {on_delete: :cascade}
      t.timestamps
    end


  end
end
