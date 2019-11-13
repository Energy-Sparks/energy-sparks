require 'rails_helper'

RSpec.describe "school alerts", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:admin, school: school)}
  let(:gas_fuel_alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, description: gas_fuel_alert_type_description) }
  let(:gas_date) { Date.parse('2019-01-01') }

  before(:each) do
    sign_in(user)
    visit root_path
  end

  it 'should show all alerts' do
    alert_run = create(:alert_generation_run, school: school)
    alert_poor = create(:alert, alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, rating: 5.0, alert_generation_run: alert_run)
    alert_good = create(:alert, alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, rating: 5.0, alert_generation_run: alert_run)
    click_on('Alert reports')
    click_on gas_fuel_alert_type.title, match: :first
    expect(page).to have_content('5.0')
  end

  it 'should give a message if no alerts' do
    click_on('Alert reports')
    expect(page.has_content?("No alerts")).to be true
  end
end
