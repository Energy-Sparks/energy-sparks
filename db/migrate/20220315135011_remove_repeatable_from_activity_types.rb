class RemoveRepeatableFromActivityTypes < ActiveRecord::Migration[6.0]
  def change
    remove_column :activity_types, :repeatable, :boolean
  end
end
