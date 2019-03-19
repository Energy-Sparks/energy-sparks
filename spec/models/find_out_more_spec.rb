require 'rails_helper'

describe FindOutMore do
  describe '.latest' do

    let(:alert_type_description)      { 'all about this alert type' }
    let(:gas_fuel_alert_type)         { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }

    it 'retrieves the latest alerts for each alert type' do
      alert_1 = create(:alert, alert_type: gas_fuel_alert_type, created_at: Date.today)
      alert_2 = create(:alert, alert_type: gas_fuel_alert_type, created_at: Date.yesterday)
      alert_3 = create(:alert, alert_type: electricity_fuel_alert_type, created_at: Date.today)
      alert_4 = create(:alert, alert_type: electricity_fuel_alert_type, created_at: Date.yesterday)

      find_out_more_type_1 = create(:find_out_more_type, alert_type: gas_fuel_alert_type)
      content_version_1 = create(:find_out_more_type_content_version, find_out_more_type: find_out_more_type_1)

      find_out_more_type_2 = create(:find_out_more_type, alert_type: electricity_fuel_alert_type)
      content_version_2 = create(:find_out_more_type_content_version, find_out_more_type: find_out_more_type_2)

      find_out_more_1 = create(:find_out_more, alert: alert_1, content_version: content_version_1, created_at: Date.today)
      find_out_more_2 = create(:find_out_more, alert: alert_2, content_version: content_version_1, created_at: Date.yesterday)
      find_out_more_3 = create(:find_out_more, alert: alert_3, content_version: content_version_2, created_at: Date.today)
      find_out_more_4 = create(:find_out_more, alert: alert_4, content_version: content_version_2, created_at: Date.yesterday)

      expect(FindOutMore.latest).to eq([find_out_more_1, find_out_more_3])
    end

  end
end
