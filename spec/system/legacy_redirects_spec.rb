require 'rails_helper'

describe 'legacy redirects', type: :system do
  let(:school) { create(:school) }

  context 'when accessing old school dashboard paths' do
    it 'redirects teacher dashboard links' do
      visit "/teachers/schools/#{school.slug}"
      expect(page).to have_current_path(school_path(school), ignore_query: true)
    end

    it 'redirects management dashboard links' do
      visit "/management/schools/#{school.slug}"
      expect(page).to have_current_path(school_path(school), ignore_query: true)
    end

    it 'redirects management priorities' do
      visit "/management/schools/#{school.slug}/management_priorities"
      expect(page).to have_current_path(priorities_school_advice_path(school), ignore_query: true)
    end

    it 'redirects find out more links' do
      visit "/schools/#{school.slug}/find_out_more"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)

      visit "/schools/#{school.slug}/find_out_more/1234"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
    end
  end

  context 'when accessing old analysis' do
    it 'redirects to new advice' do
      visit "/schools/#{school.slug}/analysis"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)

      visit "/schools/#{school.slug}/analysis/1234"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
    end
  end

  context 'when accessing old advice pages' do
    it 'redirects to new advice' do
      visit "/schools/#{school.slug}/advice/total_energy_use"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
      visit "/schools/#{school.slug}/advice/total_energy_use/insights"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
      visit "/schools/#{school.slug}/advice/total_energy_use/analysis"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
      visit "/schools/#{school.slug}/advice/total_energy_use/learn_more"
      expect(page).to have_current_path(school_advice_path(school), ignore_query: true)
    end
  end
end
