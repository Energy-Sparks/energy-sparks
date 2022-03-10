class RemoveCalendarEventTitle < ActiveRecord::Migration[6.0]
  def change
    remove_column :calendar_events, :title
  end
end
