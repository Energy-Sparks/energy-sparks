class AddDefaultImportWarningDaysToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :default_import_warning_days, :integer, default: '10'
  end
end
