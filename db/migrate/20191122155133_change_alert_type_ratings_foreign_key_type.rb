class ChangeAlertTypeRatingsForeignKeyType < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :alert_type_ratings, :alert_types
    add_foreign_key :alert_type_ratings, :alert_types, on_delete: :cascade

    remove_foreign_key :analysis_pages, :alerts
    add_foreign_key :analysis_pages, :alerts, on_delete: :cascade

    remove_foreign_key :alerts, :alert_generation_runs
    add_foreign_key :alerts, :alert_generation_runs, on_delete: :cascade
  end

  def down
    remove_foreign_key :alert_type_ratings, :alert_types
    add_foreign_key :alert_type_ratings, :alert_types, on_delete: :restrict

    remove_foreign_key :analysis_pages, :alerts
    add_foreign_key :analysis_pages, :alerts, on_delete: :restrict

    remove_foreign_key :alerts, :alert_generation_runs
    add_foreign_key :alerts, :alert_generation_runs
  end
end
