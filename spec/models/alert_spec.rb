require 'rails_helper'

describe 'Alert' do
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }

  it 'retrieves the latest alerts for each alert type' do
    alert_1 = create(:alert, alert_type: gas_fuel_alert_type, created_at: Date.today)
    alert_2 = create(:alert, alert_type: gas_fuel_alert_type, created_at: Date.yesterday)
    alert_3 = create(:alert, alert_type: electricity_fuel_alert_type, created_at: Date.today)
    alert_4 = create(:alert, alert_type: electricity_fuel_alert_type, created_at: Date.yesterday)

    expect(Alert.latest).to eq([alert_1, alert_3])
  end

  it 'has a rating of unrated if no rating is et' do
    no_rating_alert = create(:alert, rating: nil)
    expect(no_rating_alert.rating).to eq 'Unrated'
  end

  it 'has helper methods to get detail and rating data' do
    help_url = 'https://example.com'
    detail = 'The details'
    rating = 6
    alert = create(:alert, data: { 'rating' => rating, 'detail' => detail, 'help_url' => help_url })
    expect(alert.help_url).to eq help_url
    expect(alert.detail).to eq detail
    expect(alert.rating).to eq '6/10'
  end
end
