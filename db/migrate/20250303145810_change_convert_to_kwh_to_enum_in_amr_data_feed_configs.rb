class ChangeConvertToKwhToEnumInAmrDataFeedConfigs < ActiveRecord::Migration[7.2]
  def up
    create_enum :amr_data_feed_config_convert_to_kwh, %w[no m3 meter]
    execute <<~SQL.squish
      ALTER TABLE amr_data_feed_configs
        ALTER COLUMN convert_to_kwh DROP DEFAULT,
        ALTER COLUMN convert_to_kwh TYPE amr_data_feed_config_convert_to_kwh USING (
          CASE convert_to_kwh
          WHEN TRUE THEN 'm3'::amr_data_feed_config_convert_to_kwh
          ELSE 'no'::amr_data_feed_config_convert_to_kwh
          END
        ),
        ALTER COLUMN convert_to_kwh SET DEFAULT 'no'::amr_data_feed_config_convert_to_kwh
    SQL
  end

  def down
    execute <<~SQL.squish
      ALTER TABLE amr_data_feed_configs
        ALTER COLUMN convert_to_kwh DROP DEFAULT,
        ALTER COLUMN convert_to_kwh TYPE boolean USING (
          CASE convert_to_kwh
          WHEN 'm3'::amr_data_feed_config_convert_to_kwh THEN TRUE
          ELSE FALSE
          END
        ),
        ALTER COLUMN convert_to_kwh SET DEFAULT FALSE
    SQL
    drop_enum :amr_data_feed_config_convert_to_kwh
  end
end
