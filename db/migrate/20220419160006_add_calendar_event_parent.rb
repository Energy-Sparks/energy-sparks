class AddCalendarEventParent < ActiveRecord::Migration[6.0]
  def change
    add_column :calendar_events,  :based_on_id,:bigint, index: true
  end
end
