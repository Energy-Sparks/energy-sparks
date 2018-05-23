class CreateCalendarEventType < ActiveRecord::Migration[5.1]
  def change
    create_table :calendar_event_types do |t|
      t.text    :title
      t.text    :description
      t.text    :alias
      t.text    :colour
      t.boolean :term_time,         default: false
      t.boolean :holiday,           default: false
      t.boolean :school_occupied,   default: false
      t.boolean :bank_holiday,      default: false
      t.boolean :inset_day,         default: false
    end
  end
end
