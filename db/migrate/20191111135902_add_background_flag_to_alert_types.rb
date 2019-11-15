class AddBackgroundFlagToAlertTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_types, :background, :boolean, default: false
  end
end
