require 'rails_helper'

RSpec.describe "school alerts", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:user, school: school, role: :admin)}
  let(:gas_fuel_alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, description: gas_fuel_alert_type_description) }
  let(:gas_date) { Date.parse('2019-01-01') }

  before(:each) do
    sign_in(user)
    visit root_path
  end

  it 'should show all alerts' do
    alert_poor = Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :poor)
    alert_good = Alert.create(alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, status: :good)
    click_on('Alert reports')
    expect(page.has_content?(alert_poor.status)).to be true
    expect(page.has_content?(alert_good.status)).to be true
  end

  it 'should give a message if no alerts' do
    click_on('Alert reports')
    expect(page.has_content?("No weekly alerts")).to be true
    expect(page.has_content?("No termly alerts")).to be true
  end
end
