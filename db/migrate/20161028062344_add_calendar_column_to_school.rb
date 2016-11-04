class AddCalendarColumnToSchool < ActiveRecord::Migration[5.0]
  def change
    add_reference :schools, :calendar, foreign_key: true
  end
end
