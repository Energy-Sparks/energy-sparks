class AddTemplateCalendarToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :template_calendar_id, :integer, foreign_key: {to_table: :calendars, on_delete: :nullify}
  end
end
