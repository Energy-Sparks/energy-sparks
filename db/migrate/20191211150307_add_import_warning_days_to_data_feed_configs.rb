class AddImportWarningDaysToDataFeedConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :import_warning_days, :integer, default: 7, null: false
  end
end
