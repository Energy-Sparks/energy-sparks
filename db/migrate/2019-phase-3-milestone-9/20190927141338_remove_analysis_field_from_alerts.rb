class RemoveAnalysisFieldFromAlerts < ActiveRecord::Migration[6.0]
  def up
    remove_column :alert_types, :analysis
  end

  def down
    add_column :alert_types, :analysis, :text
  end
end
