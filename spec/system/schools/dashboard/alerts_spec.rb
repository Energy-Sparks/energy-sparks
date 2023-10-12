require 'rails_helper'

RSpec.shared_examples "dashboard alerts" do
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      alert_type: gas_fuel_alert_type,
      rating_from: 0,
      rating_to: 10,
      management_dashboard_alert_active: true,
    )
  end
  let!(:alert_type_rating_content_version) do
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_dashboard_title_en: 'You can save {{average_one_year_saving_gbp}} on heating in {{average_payback_years}}',
      management_dashboard_title_cy: 'Gallwch arbed {{average_one_year_saving_gbp}} mewn {{average_payback_years}}',
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
        average_payback_years: '1 year'
      },
      template_data_cy: {
        average_one_year_saving_gbp: '£7,000',
        average_payback_years: '1 flwyddyn'
      }
    )
  end

  before do
    Alerts::GenerateContent.new(test_school).perform
  end

  context 'in English' do
    it 'displays English alert text' do
      visit school_path(school, switch: true)
      expect(page).to have_content('You can save £5,000 on heating in 1 year')
    end
  end

  context 'in Welsh' do
    it 'displays Welsh alert text' do
      visit school_path(school, locale: 'cy', switch: true)
      expect(page).to have_content('Gallwch arbed £7,000 mewn 1 flwyddyn')
    end
  end
end

RSpec.describe "adult dashboard alerts", type: :system do
  let(:school) { create(:school) }

  before do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user) { nil }

    include_examples "dashboard alerts" do
      let(:test_school) { school }
    end
  end

  context 'as pupil' do
    let(:user) { create(:pupil, school: school) }

    include_examples "dashboard alerts" do
      let(:test_school) { school }
    end
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school) }

    include_examples "dashboard alerts" do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    include_examples "dashboard alerts" do
      let(:test_school) { school }
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }

    include_examples "dashboard alerts" do
      let(:test_school) { school }
    end
  end
end
