class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.string :name, null: false
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
