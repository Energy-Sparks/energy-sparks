class AddTimestampsToCalendarEvents < ActiveRecord::Migration[6.0]
  def change
    add_timestamps(:calendar_events, null: false, default: -> { "CURRENT_TIMESTAMP-INTERVAL '1 MONTH'" })
  end
end
