class AddSourceToAlertTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_types, :source, :integer, default: 0, null: false
  end
end
