class ChangeMeterDccMeterToEnum < ActiveRecord::Migration[7.1]
  def up
    create_enum :dcc_meter, %w[no smets2 other]
    execute <<~SQL.squish
      ALTER TABLE meters
        ALTER COLUMN dcc_meter DROP DEFAULT,
        ALTER COLUMN dcc_meter TYPE dcc_meter USING (
          CASE dcc_meter
          WHEN TRUE THEN 'smets2'::dcc_meter
          ELSE 'no'::dcc_meter
          END
        ),
        ALTER COLUMN dcc_meter SET DEFAULT 'no'::dcc_meter,
        ALTER COLUMN dcc_meter SET NOT NULL
    SQL
  end

  def down
    execute <<~SQL.squish
      ALTER TABLE meters
        ALTER COLUMN dcc_meter DROP DEFAULT,
        ALTER COLUMN dcc_meter TYPE boolean USING (
          CASE dcc_meter
          WHEN 'smets2'::dcc_meter THEN TRUE
          ELSE FALSE
          END
        ),
        ALTER COLUMN dcc_meter SET DEFAULT FALSE
    SQL
    drop_enum :dcc_meter
  end
end
