require 'rails_helper'

RSpec.describe 'advice pages', :include_application_helper, type: :system do
  include AdvicePageHelper

  let(:school) do
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           school_group: create(:school_group))
  end

  let(:key) { 'baseload' }
  let(:learn_more) { 'here is some more explanation' }
  let(:expected_page_title) { 'Baseload' }

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: :electricity, learn_more: learn_more) }

  context 'when error occurs' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:learn_more).and_raise(StandardError.new('testing..'))
    end

    context 'in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'shows the error page' do
        visit learn_more_school_advice_baseload_path(school)
        expect(page).to have_content('Sorry, something has gone wrong')
        expect(page).to have_content('We encountered an error attempting to generate your analysis')
      end
    end

    context 'in test' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      end

      it 'throws error' do
        expect { visit learn_more_school_advice_baseload_path(school) }.to raise_error(StandardError)
      end
    end
  end

  context 'when school doesnt have fuel type' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:school_has_fuel_type?).and_return(false)
    end

    it 'shows the no fuel type page' do
      visit school_advice_path(school)
      expect(page).to have_no_link(expected_page_title,
                                   href: school_advice_baseload_path(school))
    end

    it 'shows the error page' do
      visit insights_school_advice_baseload_path(school)
      expect(page).to have_content('Unable to run requested analysis')
    end
  end

  context 'when school doesnt have enough data' do
    let(:school) do
      create(:school,
             :with_basic_configuration_single_meter_and_tariffs,
             school_group: create(:school_group),
             reading_start_date: 1.day.ago)
    end

    it 'shows the not enough data page' do
      visit school_advice_path(school)
      within '#page-nav' do
        click_on 'Baseload'
      end
      expect(page).to have_content(I18n.t('advice_pages.not_enough_data.title'))
      expect(page).to have_content('Assuming we continue to regularly receive data')
    end
  end

  context 'as non-logged in user' do
    before do
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content(I18n.t('advice_pages.index.title'))
    end

    context 'when page is restricted' do
      before do
        advice_page.update(restricted: true)
      end

      it 'does not show the restricted advice page' do
        within '#page-nav' do
          click_on expected_page_title
        end
        expect(page).to have_content(I18n.t('advice_pages.index.title'))
        expect(page).to have_content('Only an admin or staff user for this school can access this content')
      end
    end
  end

  context 'as admin' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content(I18n.t('advice_pages.index.title'))
      within '#page-nav' do
        expect(page).to have_link(expected_page_title)
      end
    end

    context 'basic navigation checks' do
      before do
        visit learn_more_school_advice_baseload_path(school)
      end

      it 'shows the advice page' do
        expect(page).to have_content(expected_page_title)
      end

      it 'shows the nav bar' do
        within('#page-nav') do
          expect(page).to have_link(I18n.t("advice_pages.nav.pages.#{key}"), href: advice_page_path(school, advice_page))
        end
      end

      it 'shows tabs for insights, analysis, learn more' do
        within '.advice-page-tabs' do
          expect(page).to have_link('Insights')
          expect(page).to have_link('Analysis')
          expect(page).to have_link('Learn More')
        end
      end

      it 'shows breadcrumb' do
        within '.page-breadcrumb' do
          expect(page).to have_link('Schools')
          expect(page).to have_link(school.name)
          expect(page).to have_link('Advice')
          expect(page).to have_text(expected_page_title)
        end
      end

      it 'shows learn more content' do
        within '.advice-page-tabs' do
          expect(page).to have_content(learn_more)
        end
      end

      it 'links from admin page' do
        visit admin_path
        click_on 'Advice Pages'
        expect(page).to have_content('Manage advice pages')
      end

      context 'when page is restricted' do
        before do
          advice_page.update(restricted: true)
        end

        it 'shows the restricted advice page' do
          refresh
          expect(page).to have_content(expected_page_title)
        end
      end
    end
  end

  context 'for a school with non-public analysis' do
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
end
