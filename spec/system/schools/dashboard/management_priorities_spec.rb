require 'rails_helper'

RSpec.shared_examples 'dashboard priorities' do
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
  let(:alert_summary) { 'Summary of the alert' }
  let!(:alert) do
    create(:alert, :with_run,
      alert_type: gas_fuel_alert_type,
      run_on: Time.zone.today, school: test_school,
      rating: 9.0,
      template_data: {
        average_one_year_saving_gbp: '£5,000',
        average_capital_cost: '£2,000',
        one_year_saving_co2: '9,400 kg CO2',
        average_payback_years: '0 days'
      }
    )
  end

  before do
    Alerts::GenerateContent.new(test_school).perform
    visit school_path(test_school, switch: true)
  end

  it 'displays the priorities in a table' do
    expect(page).to have_content('Spending too much money on heating')
    expect(page).to have_content('£2,000')
    expect(page).to have_content('£5,000')
    expect(page).to have_content('9,400 kg CO2')
    expect(page).not_to have_content('0 days')
  end
end

RSpec.describe 'adult dashboard priorities', type: :system do
  let(:school) { create(:school) }

  before do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user) { nil }

    it_behaves_like 'dashboard priorities' do
      let(:test_school) { school }
    end
  end

  context 'as pupil' do
    let(:user) { create(:pupil, school: school) }

    it_behaves_like 'dashboard priorities' do
      let(:test_school) { school }
    end
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school) }

    it_behaves_like 'dashboard priorities' do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    it_behaves_like 'dashboard priorities' do
      let(:test_school) { school }
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }

    it_behaves_like 'dashboard priorities' do
      let(:test_school) { school }
    end
  end
end
