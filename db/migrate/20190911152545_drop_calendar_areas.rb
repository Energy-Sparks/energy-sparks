class DropCalendarAreas < ActiveRecord::Migration[6.0]
  def change
    remove_column :academic_years, :calendar_area_id, :integer
    remove_column :calendars, :calendar_area_id, :integer
    remove_column :school_groups, :default_calendar_area_id, :integer
    remove_column :schools, :calendar_area_id, :integer
    remove_column :school_onboardings, :calendar_area_id, :integer
    remove_column :scoreboards, :calendar_area_id, :integer
  end
end
