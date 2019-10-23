class AddDefaultAreasToSchoolGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :school_groups, :default_calendar_area, foreign_key: {to_table: :areas}
    add_reference :school_groups, :default_solar_pv_tuos_area, foreign_key: {to_table: :areas}
    add_reference :school_groups, :default_weather_underground_area, foreign_key: {to_table: :areas}
  end
end
