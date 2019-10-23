class AddPriorityTemplateDataToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :priority_template_data, :json, default: {}
  end
end
