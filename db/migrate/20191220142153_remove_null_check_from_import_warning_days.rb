class RemoveNullCheckFromImportWarningDays < ActiveRecord::Migration[6.0]
  def change
    change_column_null :amr_data_feed_configs, :import_warning_days, true
  end
end
