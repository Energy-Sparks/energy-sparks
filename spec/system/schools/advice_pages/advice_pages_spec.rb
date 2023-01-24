require 'rails_helper'

RSpec.describe "advice pages", type: :system do

  let(:school) { create(:school) }

  let(:key) { 'total_energy_use' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

  let(:expected_page_title) { "Total energy use" }

  context 'as non-logged in user' do

    before do
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content(expected_page_title)
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

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content(expected_page_title)
    end

    it 'shows the nav bar' do
      click_on key
      within '.advice-page-nav' do
        expect(page).to have_content("Advice")
      end
    end

    it 'shows tabs for insights, analysis, learn more' do
      click_on key
      within '.advice-page-tabs' do
        expect(page).to have_link('Insights')
        expect(page).to have_link('Analysis')
        expect(page).to have_link('Learn More')
      end
    end

    it 'shows breadcrumb' do
      click_on key
      within '.advice-page-breadcrumb' do
        expect(page).to have_link('Schools')
        expect(page).to have_link(school.name)
        expect(page).to have_link('Advice')
        expect(page).to have_text(key.humanize)
      end
    end

    it 'shows learn more content' do
      click_on key
      click_on 'Learn More'
      within '.advice-page-tabs' do
        expect(page).to have_content(learn_more)
      end
    end

    context 'when page is restricted' do
      before do
        advice_page.update(restricted: true)
      end
      it 'shows the restricted advice page' do
        click_on key
        expect(page).to have_content(expected_page_title)
      end
    end
  end
end
