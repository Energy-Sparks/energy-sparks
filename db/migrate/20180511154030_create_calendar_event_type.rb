class CreateCalendarEventType < ActiveRecord::Migration[5.1]
  def change
    create_table :calendar_event_types do |t|
      t.text    :title
      t.text    :description
      t.text    :alias
      t.text    :colour
      t.boolean :term_time, default: true
      t.boolean :holiday,   default: false
      t.boolean :occupied,  default: true
    end
  end
end
