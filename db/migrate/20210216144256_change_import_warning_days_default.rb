class ChangeImportWarningDaysDefault < ActiveRecord::Migration[6.0]
  def up
    change_column :amr_data_feed_configs, :import_warning_days, :integer, default: 10, null: true
  end
  def down
    change_column :amr_data_feed_configs, :import_warning_days, :integer, default: 7, null: true
  end
end
