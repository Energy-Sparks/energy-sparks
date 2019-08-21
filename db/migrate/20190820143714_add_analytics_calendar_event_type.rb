class AddAnalyticsCalendarEventType < ActiveRecord::Migration[6.0]
  def change
    add_column :calendar_event_types, :analytics_event_type, :integer, default: 0, null: false
  end
end
