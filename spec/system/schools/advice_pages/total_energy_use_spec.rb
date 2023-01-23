require 'rails_helper'

RSpec.describe "total energy use advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'total_energy_use' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

  let(:expected_page_title) { "Total energy use" }

  context 'as school admin' do

    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_total_energy_use_path(school)
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
        expect(page).to have_text(key.humanize)
      end
    end

    it 'shows learn more content' do
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
        refresh
        expect(page).to have_content(expected_page_title)
      end
    end
  end
end
