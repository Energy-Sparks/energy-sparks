class AddTemperaturRecordingMonthsToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :temperature_recording_months, :jsonb, default: ['10', '11', '12', '1', '2', '3', '4'] # Oct-Apr
  end
end
