class MoveCalendarAreaToOwnTable < ActiveRecord::Migration[6.0]

  def up
    create_table :calendar_areas do |t|
      t.string :title, null: false
      t.bigint :parent_id
    end
    connection.execute "INSERT INTO calendar_areas (id, title, parent_id) SELECT id, title, parent_area_id FROM areas WHERE type = 'CalendarArea'"
    connection.execute "SELECT setval('calendar_areas_id_seq', COALESCE((SELECT MAX(id)+1 FROM calendar_areas), 1), false);"

    remove_foreign_key :school_groups, :areas, column: :default_calendar_area_id
    add_foreign_key :school_groups, :calendar_areas, column: :default_calendar_area_id, on_delete: :nullify

    remove_foreign_key :school_onboardings, :areas, column: :calendar_area_id
    add_foreign_key :school_onboardings, :calendar_areas, column: :calendar_area_id, on_delete: :restrict

    add_foreign_key :calendars, :calendar_areas, on_delete: :restrict
    add_foreign_key :schools, :calendar_areas, on_delete: :restrict

    connection.execute "DELETE FROM areas WHERE type = 'CalendarArea'"
    remove_column :areas, :parent_area_id
  end

  def down
    add_reference :areas, :parent_area
    connection.execute "INSERT INTO areas (id, title, parent_area_id, type) SELECT id, title, parent_id, 'CalendarArea' FROM calendar_areas"

    remove_foreign_key :school_groups, :calendar_areas, column: :default_calendar_area_id
    add_foreign_key :school_groups, :areas, column: :default_calendar_area_id

    remove_foreign_key :school_onboardings, :calendar_areas, column: :calendar_area_id
    add_foreign_key :school_onboardings, :areas, column: :calendar_area_id, on_delete: :restrict

    remove_foreign_key :calendars, :calendar_areas, on_delete: :restrict
    remove_foreign_key :schools, :calendar_areas, on_delete: :restrict

    drop_table :calendar_areas
  end

end
