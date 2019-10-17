class DropOldDescriptionForAlertType < ActiveRecord::Migration[6.0]
  def change
    remove_column :alert_types, :_old_description, :text
  end
end
