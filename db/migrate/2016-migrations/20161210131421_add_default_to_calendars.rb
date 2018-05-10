class AddDefaultToCalendars < ActiveRecord::Migration[5.0]
  def change
    add_column :calendars, :default, :boolean
  end
end
