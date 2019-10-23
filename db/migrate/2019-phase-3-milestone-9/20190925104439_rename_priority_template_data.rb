class RenamePriorityTemplateData < ActiveRecord::Migration[6.0]
  def change
    rename_column :alerts, :priority_template_data, :priority_data
  end
end
