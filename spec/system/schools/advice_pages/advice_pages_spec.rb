require 'rails_helper'

RSpec.describe 'advice pages', type: :system do
  include_context 'electricity advice page'

  let(:key) { 'total_energy_use' }
  let(:learn_more) { 'here is some more explanation' }
  let(:expected_page_title) { 'Energy usage summary' }

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more, fuel_type: nil) }

  context 'when error occurs' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:learn_more).and_raise(StandardError.new('testing..'))
    end

    context 'in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'shows the error page' do
        visit learn_more_school_advice_total_energy_use_path(school)
        expect(page).to have_content('Sorry, something has gone wrong')
        expect(page).to have_content('We encountered an error attempting to generate your analysis')
      end
    end

    context 'in test' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      end

      it 'throws error' do
        expect { visit learn_more_school_advice_total_energy_use_path(school) }.to raise_error(StandardError)
      end
    end
  end

  context 'when school doesnt have fuel type' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:school_has_fuel_type?).and_return(false)
    end

    it 'shows the no fuel type page' do
      visit school_advice_path(school)
      within '#page-nav' do
        click_on 'Energy use summary'
      end
      expect(page).to have_content('Unable to run requested analysis')
    end
  end

  context 'when school doesnt have enough data' do
    let(:data_available_from) { nil }
    let(:analysable) do
      OpenStruct.new(
        enough_data?: false,
        data_available_from: data_available_from
      )
    end

    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:create_analysable).and_return(analysable)
    end

    it 'shows the not enough data page' do
      visit school_advice_path(school)
      within '#page-nav' do
        click_on 'Energy use summary'
      end
      expect(page).to have_content('Not enough data to run analysis')
      expect(page).not_to have_content('Assuming we continue to regularly receive data')
    end

    context 'and we can estimate a date' do
      let(:data_available_from) { Date.today + 10 }

      it 'also includes the data' do
        visit school_advice_path(school)
        within '#page-nav' do
          click_on 'Energy use summary'
        end
        expect(page).to have_content("Assuming we continue to regularly receive data we expect this analysis to be available after #{data_available_from.to_s(:es_short)}")
      end
    end
  end

  context 'as non-logged in user' do
    before do
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Energy efficiency advice')
      expect(page).to have_link('Energy use summary')
    end

    context 'when page is restricted' do
      before do
        advice_page.update(restricted: true)
      end

      it 'does not show the restricted advice page' do
        within '#page-nav' do
          click_on 'Energy use summary'
        end
        expect(page).to have_content('Energy efficiency advice')
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
      expect(page).to have_content('Energy efficiency advice')
      within '#page-nav' do
        expect(page).to have_link('Energy use summary')
      end
    end

    context 'basic navigation checks' do
      before do
        visit learn_more_school_advice_total_energy_use_path(school)
      end

      it 'shows the advice page' do
        expect(page).to have_content(expected_page_title)
      end

      it 'shows the nav bar' do
        within '.advice-page-nav' do
          expect(page).to have_content('Advice')
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
        expect(page).not_to have_link(login_text)
      end
    end
  end
end
