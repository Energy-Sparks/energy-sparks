class AddCalendarTypeToCalendar < ActiveRecord::Migration[6.0]
  def change
    add_column :calendars, :calendar_type, :integer
  end
end
