class AddWelshTemplateDataToAlert < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :template_data_cy, :json, default: {}
  end
end
