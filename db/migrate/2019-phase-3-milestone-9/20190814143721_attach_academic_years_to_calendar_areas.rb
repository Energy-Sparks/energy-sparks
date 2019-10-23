class AttachAcademicYearsToCalendarAreas < ActiveRecord::Migration[6.0]
  def change
    add_reference :academic_years, :calendar_area, foreign_key: {on_delete: :cascade}
    reversible do |dir|
      dir.up do
        connection.execute 'UPDATE academic_years SET calendar_area_id = (SELECT id FROM calendar_areas WHERE parent_id IS NULL LIMIT 1)'
      end
    end
    change_column_null :academic_years, :calendar_area_id, false
    change_column_null :calendars, :calendar_area_id, false
  end
end
