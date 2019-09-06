class AddCalendarToAcademicYear < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_years, :based_on_calendar_id, :integer
  end
end
