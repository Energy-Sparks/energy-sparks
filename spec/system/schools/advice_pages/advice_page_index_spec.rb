require 'rails_helper'

RSpec.describe "advice pages", type: :system do

  let(:key) { 'total_energy_use' }
  let!(:advice_page) { create(:advice_page, key: key) }

  let(:school)             { create(:school) }

  context 'default index' do
    before(:each) do
      allow_any_instance_of(School).to receive(:has_electricity?).and_return(true)
      visit school_advice_path(school)
    end

    it "has an active overview tab" do
      expect(page).to have_link('Overview', class: 'active')
    end

    it 'shows the list of pages' do
      expect(page).to have_content(I18n.t("advice_pages.nav.pages.#{key}"))
      expect(page).to have_content(I18n.t("advice_pages.index.show.page_summary.#{key}"))
    end
  end

  context 'with management priorities' do
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
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: gas_fuel_alert_type,
        run_on: Date.today, school: school,
        rating: 9.0,
        template_data: {
          average_one_year_saving_gbp: '£5,000',
          average_capital_cost: '£2,000',
          one_year_saving_co2: '9,400 kg CO2',
          one_year_saving_kwh: '6,500 kWh',
          average_payback_years: '0 days'
        }
      )
    end

    before do
      Alerts::GenerateContent.new(school).perform
      visit school_advice_path(school)
      click_on ('Priority actions')
    end

    it "has an active priorities tab" do
      expect(page).to have_link('Priority actions', class: 'active')
    end

    it 'displays the priorities in a table' do
      expect(page).to have_content('Spending too much money on heating')
      expect(page).to have_content('£5,000')
      expect(page).to have_content('9,400')
      expect(page).to have_content('6,500')
    end

  end

  context 'with dashboard alerts' do
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
    let(:alert_summary){ 'Summary of the alert' }
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: gas_fuel_alert_type,
        run_on: Date.today, school: school,
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
      Alerts::GenerateContent.new(school).perform
      visit school_advice_path(school)
      click_on ('Recent alerts')
    end

    context 'in English' do
      it "has an active alerts tab" do
        expect(page).to have_link('Recent alerts', class: 'active')
      end

      it "displays the alert group" do
        expect(page).to have_content('Long term trends and advice')
      end

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

  context 'for a non-public school' do
    before { school.update(public: false) }
    let(:user) {}
    let(:login_text) { 'Log in with your email address and password' }

    before do
      sign_in(user) if user
      visit school_advice_path(school)
    end

    context 'logged out user' do
      it 'shows login page' do
        expect(page).to have_link(login_text)
      end
    end

    context 'school user' do
      let(:user) { create(:staff, school: school) }
      it 'does not show login page' do
        expect(page).to_not have_link(login_text)
      end
    end
  end
end
