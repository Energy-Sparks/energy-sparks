class ChangeObservationActivityForeignKey < ActiveRecord::Migration[6.0]
  def up
    add_column :observations, :visible, :boolean, default: true
    remove_foreign_key :observations, :activities
    add_foreign_key :observations, :activities, on_delete: :nullify
  end
  def down
    remove_column :observations, :visible
    remove_foreign_key :observations, :activities
    add_foreign_key :observations, :activities, on_delete: :cascade
  end
end
