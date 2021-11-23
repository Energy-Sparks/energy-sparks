require 'rails_helper'

RSpec.describe "school alerts", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:admin) }
  let(:gas_fuel_alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, description: gas_fuel_alert_type_description) }
  let(:gas_date) { Date.parse('2019-01-01') }

  before(:each) do
    sign_in(user)
    visit school_path(school)
  end

  it 'should show all alerts' do
    alert_run = create(:alert_generation_run, school: school)
    alert_poor = create(:alert, alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, rating: 5.0, alert_generation_run: alert_run)
    alert_good = create(:alert, alert_type: gas_fuel_alert_type, run_on: gas_date, school: school, rating: 5.0, alert_generation_run: alert_run)
    click_on('Batch reports')
    click_on('Alert reports')
    click_on 'View'
    expect(page).to have_content('5.0')
  end

end
