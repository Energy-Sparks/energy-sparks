require 'rails_helper'

RSpec.describe 'advice pages', :include_application_helper, type: :system do
  include AdvicePageHelper

  let(:key) { 'baseload' }
  let!(:advice_page) { create(:advice_page, key: key) }

  let(:reading_start_date) { 1.year.ago }
  let(:reading_end_date) { Time.zone.today }

  let(:school) do
    # creates a school with just an electricity meter, ensure fuel configuration matches
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           has_gas: false,
           has_solar_pv: false,
           has_storage_heaters: false)
  end

  context 'with new dashboard feature active' do
    let(:user) { nil }
    let(:dashboard_charts) { [] }

    before do
      Flipper.enable(:new_dashboards_2024)
      school.configuration.update(dashboard_charts: dashboard_charts)
      sign_in(user) if user.present?
      visit school_advice_path(school)
    end

    it { expect(page).to have_title(I18n.t('advice_pages.index.title')) }
    it { expect(page).to have_content(I18n.t('advice_pages.index.title')) }
    it { expect(page.body).to include(I18n.t('advice_pages.index.show.intro_html')) }
    it { expect(page).to have_link(I18n.t('advice_pages.nav.overview'), href: school_advice_path(school)) }

    # no links if no alerts or priorities to display
    it { expect(page).not_to have_link(href: alerts_school_advice_path(school)) }
    it { expect(page).not_to have_link(href: priorities_school_advice_path(school)) }

    it 'shows links in navbar' do
      within('#page-nav') do
        expect(page).to have_link(I18n.t("advice_pages.nav.pages.#{key}"), href: advice_page_path(school, advice_page))
      end
    end

    it 'shows the list of pages' do
      expect(page).to have_content(I18n.t("advice_pages.nav.pages.#{key}"))
      expect(page).to have_content(I18n.t("advice_pages.index.show.page_summary.#{key}"))
    end

    context 'when school has no public analysis' do
      let(:school) { create(:school, data_sharing: :within_group) }
      let(:login_text) { 'Log in with your email address and password' }

      it 'shows login page' do
        expect(page).to have_link(login_text)
      end

      context 'with a school user' do
        let(:user) { create(:staff, school: school) }

        it 'does not show login page' do
          expect(page).not_to have_link(login_text)
        end
      end
    end

    context 'when school is inactive' do
      let(:school) { create(:school, active: false) }

      it 'returns 410 for an inactive school' do
        expect(page.status_code).to eq(410)
      end
    end

    context 'when rendering charts' do
      context 'with no charts to display' do
        it { expect(page).not_to have_css('#management-energy-overview') }
      end

      context 'with charts available' do
        let(:dashboard_charts) do
          [:management_dashboard_group_by_week_electricity,
           :management_dashboard_group_by_week_gas,
           :management_dashboard_group_by_week_storage_heater,
           :management_dashboard_group_by_month_solar_pv]
        end

        it 'displays the expected charts' do
          expect(page).to have_css('#management-energy-overview')
          expect(page).to have_css('#electricity-overview')
          expect(page).to have_css('#gas-overview')
          expect(page).to have_css('#storage_heater-overview')
          expect(page).to have_css('#solar-overview')
          dashboard_charts.each do |chart|
            expect(page).to have_css("#chart_wrapper_#{chart}")
          end
        end
      end
    end

    context 'when school is not data enab;ed' do
      it 'should redirect the user'
      context 'with an admin' do
        it 'should not redirect the user'
      end
    end

    context 'with dashboard alerts' do
      include_context 'with dashboard alerts'

      before do
        visit school_advice_path(school) # reload to pickup alert content
      end

      it {
        expect(page).to have_link("#{I18n.t('advice_pages.index.alerts.title')} (2)",
                                     href: alerts_school_advice_path(school))
      }

      context 'it shows the alerts' do
        before do
          click_on "#{I18n.t('advice_pages.index.alerts.title')} (2)"
        end

        it 'displays the alert group' do
          expect(page).to have_content('Long term trends and advice')
        end

        it 'displays English alert text' do
          expect(page).to have_content('You can save £5,000 on heating in 1 year')
        end
      end
    end

    context 'with management priorities' do
      include_context 'with dashboard alerts'

      before do
        visit school_advice_path(school) # reload to pickup alert content
      end

      it {
        expect(page).to have_link("#{I18n.t('advice_pages.index.priorities.title')} (2)",
                                     href: priorities_school_advice_path(school))
      }

      context 'it shows the priorities' do
        before do
          click_on "#{I18n.t('advice_pages.index.priorities.title')} (2)"
        end

        it 'displays English alert text' do
          expect(page).to have_content('Save on heating')
          expect(page).to have_content('High baseload')
        end
      end
    end

    context 'with enough data to compare electricity' do
      it 'shows the fuel comparison' do
        expect(page).to have_css('#electricity-comparison')
        expect(page).to have_content(I18n.t('components.comparison_overview.title'))
      end
    end
  end

  context 'default index' do
    before do
      allow_any_instance_of(School).to receive(:has_electricity?).and_return(true)
      visit school_advice_path(school)
    end

    it 'has an active overview tab' do
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
    let(:alert_summary) { 'Summary of the alert' }
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: gas_fuel_alert_type,
        run_on: Time.zone.today, school: school,
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
      click_on(I18n.t('advice_pages.index.priorities.title'))
    end

    it 'has an active priorities tab' do
      expect(page).to have_link(I18n.t('advice_pages.index.priorities.title'), class: 'active')
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
    let(:alert_summary) { 'Summary of the alert' }
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: gas_fuel_alert_type,
        run_on: Time.zone.today, school: school,
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
      click_on('Recent alerts')
    end

    context 'in English' do
      it 'has an active alerts tab' do
        expect(page).to have_link('Recent alerts', class: 'active')
      end

      it 'displays the alert group' do
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

  context 'for a non-public with non-public analysis' do
    before do
      school.update(data_sharing: :within_group)
      sign_in(user) if user
      visit school_advice_path(school)
    end

    let(:user) {}
    let(:login_text) { 'Log in with your email address and password' }

    context 'logged out user' do
      it 'shows login page' do
        expect(page).to have_link(login_text)
      end
    end

    context 'school user' do
      let(:user) { create(:staff, school: school) }

      it 'does not show login page' do
        expect(page).not_to have_link(login_text)
      end
    end
  end

  it 'shows 410 for an inactive school' do
    school.update(active: false)
    visit school_advice_path(school)
    expect(page.status_code).to eq(410)
  end
end
