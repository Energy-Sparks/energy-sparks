require 'rails_helper'

RSpec.describe "advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'baseload' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page_baseload) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

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
      expect(page).to have_content("Advice page: #{key.humanize}")
    end

    context 'when page is restricted' do
      before do
        advice_page_baseload.update(restricted: true)
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
      expect(page).to have_content("Advice page: #{key.humanize}")
    end

    it 'shows the nav bar' do
      click_on key
      within '.advice-page-nav' do
        expect(page).to have_content("Menu")
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

    it 'shows analysis content' do
      annual_baseload_usage = double(kwh: 123.0, £: 1.0, co2: 1.0)
      baseload_usage = double(kwh: 1.0, £: 1.0, co2: 1.0)
      estimated_savings = double(kwh: 1.0, £: 1.0, co2: 1.0)

      baseload_calculation_service = double(annual_baseload_usage: annual_baseload_usage)
      allow(Baseload::BaseloadCalculationService).to receive(:new).and_return(baseload_calculation_service)

      benchmark_calculation_service = double(baseload_usage: baseload_usage, estimated_savings: estimated_savings)
      allow(Baseload::BaseloadBenchmarkingService).to receive(:new).and_return(benchmark_calculation_service)

      click_on key
      click_on 'Analysis'
      within '.advice-page-tabs' do
        expect(page).to have_content('Recent trend')
        expect(page).to have_content('baseload over the last 12 months was 123 kW')
      end
    end

    context 'when page is restricted' do
      before do
        advice_page_baseload.update(restricted: true)
      end
      it 'shows the restricted advice page' do
        click_on key
        expect(page).to have_content("Advice page: #{key.humanize}")
      end
    end
  end
end
