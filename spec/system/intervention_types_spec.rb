require 'rails_helper'

describe 'intervention types', type: :system do
  context 'intervention types search page' do
    let!(:intervention_type_1) { create(:intervention_type, name: 'foo', description: 'intervention') }
    let!(:intervention_type_2) { create(:intervention_type, name: 'bar', description: 'second intervention') }

    it 'links from intervention groups page and shows empty page' do
      visit intervention_type_groups_path
      click_on 'Search'

      expect(page).to have_text('Find actions')
      expect(page).to have_no_text('No results found')
    end

    it 'links to intervention categories page' do
      visit search_intervention_types_path
      click_on 'All actions'

      expect(page).to have_text('Explore energy saving actions')
    end

    it 'links to interventions page' do
      visit search_intervention_types_path
      click_on 'Pupil activities'

      expect(page).to have_text('Explore energy saving activities')
    end

    it 'shows search results' do
      visit search_intervention_types_path
      fill_in 'query', with: 'foo'
      click_on 'Search'

      expect(page).to have_text(intervention_type_1.name)
    end

    it 'paginates search results' do
      run_with_temporary_pagy_default(limit: 1) do
        visit search_intervention_types_path
        fill_in 'query', with: 'intervention'
        click_on 'Search'

        expect(page).to have_text(intervention_type_1.name)
        expect(page).to have_no_text(intervention_type_2.name)

        click_on 'Next'

        expect(page).to have_no_text(intervention_type_1.name)
        expect(page).to have_text(intervention_type_2.name)
      end
    end

    it 'shows no results' do
      visit search_intervention_types_path
      fill_in 'query', with: 'blah'
      click_on 'Search'

      expect(page).to have_text('No results found')
    end
  end
end
