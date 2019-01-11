class AddConstraintForAlerts < ActiveRecord::Migration[5.2]
  def up
    execute(%Q{
    ALTER TABLE alerts
    ADD CONSTRAINT unique_alerts UNIQUE(school_id, alert_type_id, run_on);
    })
  end

  def down
    execute(%Q{
    ALTER TABLE alerts
    DROP CONSTRAINT unique_alerts;
    })
  end
end
