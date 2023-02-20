require 'rails_helper'

RSpec.describe "advice pages", type: :system do

  include_context "electricity advice page"

  let(:key) { 'total_energy_use' }
  let(:learn_more) { 'here is some more explanation' }
  let(:expected_page_title) { "Energy usage summary" }

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

  context 'when error occurs' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:learn_more).and_raise(StandardError.new('testing..'))
    end
    it 'shows the error page' do
      visit learn_more_school_advice_total_energy_use_path(school)
      expect(page).to have_content('Sorry, something has gone wrong')
      expect(page).to have_content('We encountered an error attempting to generate your analysis')
    end
  end

  context 'when school doesnt have fuel type' do
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:school_has_fuel_type?).and_return(false)
    end
    it 'shows the no fuel type page' do
      visit school_advice_path(school)
      click_on key
      expect(page).to have_content('Unable to run requested analysis')
    end
  end

  context 'when school doesnt have enough data' do
    let(:data_available_from)  { nil }
    let(:analysable) {
      OpenStruct.new(
        enough_data?: false,
        data_available_from: data_available_from
      )
    }
    before do
      allow_any_instance_of(Schools::Advice::AdviceBaseController).to receive(:create_analysable).and_return(analysable)
    end
    it 'shows the not enough data page' do
      visit school_advice_path(school)
      click_on key
      expect(page).to have_content('Not enough data to run analysis')
      expect(page).to_not have_content('Assuming we continue to regularly receive data')
    end
    context 'and we can estimate a date' do
      let(:data_available_from) { Date.today + 10 }
      it 'also includes the data' do
        visit school_advice_path(school)
        click_on key
        expect(page).to have_content("Assuming we continue to regularly receive data we expect this analysis to be available after #{data_available_from.to_s(:es_short)}")
      end
    end
  end


  context 'as non-logged in user' do

    before do
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    context 'when page is restricted' do
      before do
        advice_page.update(restricted: true)
      end
      it 'does not show the restricted advice page' do
        click_on key
        expect(page).to have_content('Advice Pages')
        expect(page).to have_content("Only an admin or staff user for this school can access this content")
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
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    context 'basic navigation checks' do
      before(:each) do
        visit learn_more_school_advice_total_energy_use_path(school)
      end

      it 'shows the advice page' do
        expect(page).to have_content(expected_page_title)
      end

      it 'shows the nav bar' do
        within '.advice-page-nav' do
          expect(page).to have_content("Advice")
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
        within '.advice-page-breadcrumb' do
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

      it 'links to advice pages from manage school menu' do
        within '#manage_school_menu' do
          click_on 'Advice pages'
        end
        expect(page).to have_content("Advice Pages")
        expect(page).to have_content("All pages")
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
end
