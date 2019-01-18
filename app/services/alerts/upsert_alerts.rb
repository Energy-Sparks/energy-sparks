require 'upsert/active_record_upsert'

module Alerts
  class UpsertAlerts
    def initialize(alerts)
      @alerts = alerts
      @update_create_time = Time.now.utc
    end

    def perform
      @alerts.each do |alert|
        upsert_alert(alert)
      end
    end

  private

    def upsert_alert(alert)
      # to_json is required because upsert supports Hstore but not JSON
      Alert.upsert({ school_id: alert.school_id, alert_type_id: alert.alert_type_id, run_on: alert.run_on },
        status: alert.status,
        summary: alert.summary,
        data: alert.data.to_json,
        updated_at: @update_create_time,
        created_at: @update_create_time
      )
    end
  end
end
