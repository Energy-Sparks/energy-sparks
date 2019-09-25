class AddManagementPriorities < ActiveRecord::Migration[6.0]
  def change
    create_table :management_priorities do |t|
      t.references :content_generation_run, null: false, foreign_key: {on_delete: :cascade}
      t.references :alert, null: false, foreign_key: {on_delete: :cascade}
      t.references :find_out_more, foreign_key: {on_delete: :nullify}
      t.references :alert_type_rating_content_version, null: false, foreign_key: {on_delete: :restrict}, index: {name: 'mp_altrcv'}
      t.timestamps
    end
  end
end
