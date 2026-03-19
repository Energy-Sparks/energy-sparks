class RemoveImportWarningDaysFromDataConfigs < ActiveRecord::Migration[7.2]
  def change
    remove_column :amr_data_feed_configs, :import_warning_days, :integer
  end
end
