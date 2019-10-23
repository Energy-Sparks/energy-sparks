class RemoveOldDescriptions < ActiveRecord::Migration[6.0]
  def change
    remove_column :programmes, :_old_description, :text
    remove_column :programme_types, :_old_description, :text
  end
end
