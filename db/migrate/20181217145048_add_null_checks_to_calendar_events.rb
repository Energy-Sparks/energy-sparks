class AddNullChecksToCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    change_column_null :calendar_events, :start_date, false
    change_column_null :calendar_events, :end_date, false
    change_column_null :calendar_events, :calendar_id, false
  end
end
