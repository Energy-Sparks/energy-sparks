class CreateCalendarEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :calendar_events do |t|
      t.references :calendar, foreign_key: true
      t.references :calendar_event_type, foreign_key: true
      t.date       :start_date
      t.date       :end_date
    end
  end
end
