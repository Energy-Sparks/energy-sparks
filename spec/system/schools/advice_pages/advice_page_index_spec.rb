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

  let(:user) { nil }
  let(:dashboard_charts) { [] }

  before do
    school.configuration.update(dashboard_charts: dashboard_charts)
    sign_in(user) if user.present?
  end

  context 'when school is not cached' do
    context 'when school is data-enabled' do
      describe 'serves a holding page until data is cached' do
        before do
          allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        end

        # non-javascript version of test to check that right template is delivered
        context 'displays the holding page template' do
          it 'renders a loading page' do
            visit school_advice_path(school)
            expect(page).to have_content("Energy Sparks is processing all of this school's data to provide today's analysis")
            expect(page).to have_content("Once we've finished, we will re-direct you to the school dashboard")
          end
        end

        context 'with a successful ajax load', :js do
          it 'renders a loading page and then back to the dashboard page on success' do
            visit school_advice_path(school)
            expect(page).to have_title(I18n.t('advice_pages.index.title'))
            # if redirect fails it will still be processing
            expect(page).not_to have_content('processing')
            expect(page).not_to have_content("we're having trouble processing your energy data today")
          end
        end

        context 'with an ajax loading error', :js do
          before do
            allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_raise(StandardError, 'It went wrong')
          end

          it 'shows an error message', :errors_expected do
            visit school_advice_path(school)
            expect(page).to have_content("we're having trouble processing your energy data today")
          end
        end
      end
    end

    context 'when school is not data-enabled' do
      before do
        school.update!(data_enabled: false)
        visit school_advice_path(school)
      end

      describe 'it does not show a loading page' do
        before do
          allow(AggregateSchoolService).to receive(:caching_off?).and_return(false)
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        end

        it 'and redirects to pupil dashboard' do
          expect(page).to have_content("We're setting up this school's energy data and will update this page when it is ready to explore")
        end
      end
    end
  end

  context 'with a data enabled school' do
    before do
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
      before do
        create(:advice_page, key: :electricity_long_term, fuel_type: :electricity)
        meter_collection = AggregateSchoolService.new(school).aggregate_school
        Schools::AdvicePageBenchmarks::GenerateBenchmarks.new(school: school, aggregate_school: meter_collection).generate!
        refresh
      end

      it 'shows the fuel comparison' do
        expect(page).to have_css('#electricity-comparison')
        expect(page).to have_content(I18n.t('components.comparison_overview.title'))
      end
    end
  end
end
