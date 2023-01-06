require 'rails_helper'

RSpec.describe "advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'baseload-tester' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page) { create(:advice_page, key: key, learn_more: learn_more) }

  context 'as admin' do

    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice')
      expect(page).to have_link(key)
    end

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content("Advice page: #{key.humanize}")
    end

    it 'shows the nav bar' do
      click_on key
      within '.advice-page-nav' do
        expect(page).to have_content("Pages")
        expect(page).to have_link(key)
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
      end
    end

    it 'shows learn more content' do
      click_on key
      click_on 'Learn More'
      within '.advice-page-tabs' do
        expect(page).to have_content(learn_more)
      end
    end

  end
end
