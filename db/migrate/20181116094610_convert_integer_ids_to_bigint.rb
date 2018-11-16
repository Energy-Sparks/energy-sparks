class ConvertIntegerIdsToBigint < ActiveRecord::Migration[5.2]
  def tables_and_columns
    {
      'activity_categories' => %w[id],
      'areas' => %w[parent_area_id],
      'badges_sashes' => %w[id badge_id sash_id],
      'bank_holidays' => %w[calendar_area_id],
      'activity_type_suggestions' => %w[id activity_type_id suggested_type_id],
      'friendly_id_slugs' => %w[id sluggable_id],
      'merit_actions' => %w[id user_id target_id],
      'merit_activity_logs' => %w[id action_id related_change_id],
      'merit_score_points' => %w[id score_id],
      'merit_scores' => %w[id sash_id],
      'sashes' => %w[id],
      'meter_readings' => %w[id meter_id],
      'taggings' => %w[id tag_id taggable_id tagger_id],
      'tags' => %w[id],
      'activity_types' => %w[id activity_category_id],
      'activities' => %w[id school_id activity_type_id activity_category_id],
      'calendars' => %w[id based_on_id calendar_area_id],
      'terms' => %w[id calendar_id],
      'meters' => %w[id school_id],
      'data_feeds' => %w[area_id],
      'users' => %w[id school_id],
      'schools' => %w[id sash_id calendar_id calendar_area_id temperature_area_id solar_irradiance_area_id met_office_area_id weather_underground_area_id solar_pv_tuos_area_id]
    }
  end

  def up
    tables_and_columns.each do |table_name, columns|
      columns.each do |column_name|
        change_column table_name, column_name, :bigint
      end
    end
  end

  def down
    tables_and_columns.each do |table_name, columns|
      columns.each do |column_name|
        change_column table_name, column_name, :integer
      end
    end
  end
end
