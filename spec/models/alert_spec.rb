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

  it 'retrieves the latest alerts for each alert type but ignores if there is an exception' do
    school = create(:school)

    alert_1 = create(:alert, school: school, alert_type: gas_fuel_alert_type, created_at: Date.today)
    alert_2 = create(:alert, school: school, alert_type: gas_fuel_alert_type, created_at: Date.yesterday)
    alert_3 = create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Date.today)
    alert_4 = create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Date.yesterday)

    expect(Alert.without_exception.latest).to eq([alert_1, alert_3])

    SchoolAlertTypeException.create(school: school, alert_type: gas_fuel_alert_type)
    expect(Alert.without_exception.latest).to eq([alert_3])
  end

  it 'has a rating of unrated if no rating is et' do
    no_rating_alert = create(:alert, rating: nil)
    expect(no_rating_alert.formatted_rating).to eq 'Unrated'
  end
end
