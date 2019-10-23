class AddCalendarsToTables < ActiveRecord::Migration[6.0]
  def change
    add_reference :scoreboards, :academic_year_calendar,      foreign_key: {to_table: :calendars, on_delete: :nullify}
    add_reference :school_groups, :default_template_calendar, foreign_key: {to_table: :calendars, on_delete: :nullify}
    add_reference :school_onboardings, :template_calendar,    foreign_key: {to_table: :calendars, on_delete: :nullify}
  end
end
