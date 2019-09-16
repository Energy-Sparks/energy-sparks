class AddCalendarToAcademicYear < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_years, :calendar_id, :integer
  end
end
