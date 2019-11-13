require 'rails_helper'

describe 'Management dashboard' do

  let!(:school){ create(:school) }
  let(:staff){ create(:staff, school: school, staff_role: create(:staff_role, :management)) }
  let!(:intervention){ create(:observation, school: school) }

  before(:each) do
    sign_in(staff)
  end

  it 'allows login and access to management dashboard' do
    visit root_path
    expect(page).to have_content("#{school.name}")
    expect(page).to have_content("Energy Usage")

    expect(page).to have_content("Recorded temperatures")
  end

  describe 'with management priorities' do

    let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        alert_type: gas_fuel_alert_type,
        rating_from: 0,
        rating_to: 10,
        management_priorities_active: true,
      )
    end
    let!(:alert_type_rating_content_version) do
      create(
        :alert_type_rating_content_version,
        alert_type_rating: alert_type_rating,
        management_priorities_title: 'Spending too much money on heating',
      )
    end
    let(:alert_summary){ 'Summary of the alert' }
    let(:alert_generation_run) { create(:alert_generation_run, school: school) }
    let!(:alert) do
      Alert.create(
        alert_type: gas_fuel_alert_type,
        run_on: Date.today, school: school,
        rating: 9.0,
        template_data: {
          average_capital_cost: '£2,000'
        },
        alert_generation_run: alert_generation_run
      )
    end

    before do
      Alerts::GenerateContent.new(school).perform
    end

    it 'displays the priorities in a table' do
      visit root_path
      expect(page).to have_content('Spending too much money on heating')
      expect(page).to have_content('£2,000')
    end
  end

end
