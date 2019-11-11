class AddAnalysisAlertContent < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_ratings, :analysis_active, :boolean, default: false
    add_column :alert_type_rating_content_versions, :analysis_title, :string
    add_column :alert_type_rating_content_versions, :analysis_subtitle, :string
    add_column :alert_type_rating_content_versions, :analysis_start_date, :date
    add_column :alert_type_rating_content_versions, :analysis_end_date, :date
    add_column :alert_type_rating_content_versions, :analysis_weighting, :decimal, default: 5.0

    create_table :analysis_pages do |t|
      t.references :content_generation_run, foreign_key: {on_delete: :cascade}
      t.references :alert_type_rating_content_version, foreign_key: {on_delete: :restrict}
      t.references :alert, foreign_key: {on_delete: :restrict}
      t.timestamps
    end
  end
end
