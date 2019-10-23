class AddMissingFKs < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key "academic_years", "calendars",on_delete: :restrict
    add_foreign_key "calendars", "calendars", column: "based_on_id", on_delete: :restrict
  end
end
