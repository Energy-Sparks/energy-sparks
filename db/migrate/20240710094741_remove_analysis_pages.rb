class RemoveAnalysisPages < ActiveRecord::Migration[7.1]
  def change
    drop_table :analysis_pages do |t|
      t.references :content_generation_run, foreign_key: {on_delete: :cascade}
      t.references :alert_type_rating_content_version, foreign_key: {on_delete: :restrict}
      t.references :alert, foreign_key: {on_delete: :restrict}
      t.integer :category
      t.decimal :priority, default: 0.0
      t.timestamps
    end
  end
end
