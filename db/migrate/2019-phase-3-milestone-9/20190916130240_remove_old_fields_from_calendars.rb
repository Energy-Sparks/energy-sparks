class RemoveOldFieldsFromCalendars < ActiveRecord::Migration[6.0]
  def change
    remove_column :calendars, :template, :boolean
    remove_column :calendars, :default, :boolean
    remove_column :calendars, :deleted, :boolean
  end
end
