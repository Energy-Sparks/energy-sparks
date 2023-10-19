require 'rails_helper'

describe 'intervention types', type: :system do
  context 'intervention types search page' do
    let!(:intervention_type_1) { create(:intervention_type, name: 'foo', description: 'intervention') }
    let!(:intervention_type_2) { create(:intervention_type, name: 'bar', description: 'second intervention') }

    it 'links from intervention groups page and shows empty page' do
      ClimateControl.modify FEATURE_FLAG_INTERVENTION_TYPE_SEARCH: 'true' do
        visit intervention_type_groups_path
        click_on 'Search'

        expect(page).to have_content('Find actions')
        expect(page).not_to have_content('No results found')
      end
    end

    it 'link is feature flag controlled' do
      ClimateControl.modify FEATURE_FLAG_INTERVENTION_TYPE_SEARCH: 'false' do
        visit intervention_type_groups_path
        expect(page).not_to have_link('Search')
      end
    end

    it 'links to intervention categories page' do
      visit search_intervention_types_path
      click_on 'All actions'

      expect(page).to have_content('Explore energy saving actions')
    end

    it 'links to interventions page' do
      visit search_intervention_types_path
      click_on 'Pupil activities'

      expect(page).to have_content('Explore energy saving activities')
    end

    it 'shows search results' do
      visit search_intervention_types_path
      fill_in 'query', with: 'foo'
      click_on 'Search'

      expect(page).to have_content(intervention_type_1.name)
    end

    it 'paginates search results' do
      Pagy::DEFAULT[:items] = 1
      visit search_intervention_types_path
      fill_in 'query', with: 'intervention'
      click_on 'Search'

      expect(page).to have_content(intervention_type_1.name)
      expect(page).not_to have_content(intervention_type_2.name)

      click_on 'Next'

      expect(page).not_to have_content(intervention_type_1.name)
      expect(page).to have_content(intervention_type_2.name)

      # reset this to prevent problems with other tests..
      Pagy::DEFAULT[:items] = 20
    end

    it 'shows no results' do
      visit search_intervention_types_path
      fill_in 'query', with: 'blah'
      click_on 'Search'

      expect(page).to have_content('No results found')
    end
  end
end
