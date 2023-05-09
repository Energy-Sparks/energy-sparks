class AddImportWarningDaysToDataSource < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sources, :import_warning_days, :integer, default: nil
  end
end
