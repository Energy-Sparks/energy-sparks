class UpdateCalendar < ActiveRecord::Migration[6.0]
  def change
    add_column :calendars, :term_calendar, :boolean, default: false, null: false
    add_column :calendars, :bank_holiday_calendar, :boolean, default: false, null: false
  end
end
