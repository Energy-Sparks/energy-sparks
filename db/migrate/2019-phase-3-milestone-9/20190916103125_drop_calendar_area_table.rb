class DropCalendarAreaTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :calendar_areas
  end
end
