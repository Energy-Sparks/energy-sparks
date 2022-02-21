require 'rails_helper'

describe 'activity types', type: :system do

  let!(:activity_type_1) { create(:activity_type, name: 'foo') }
  let!(:activity_type_2) { create(:activity_type, name: 'bar') }

  context 'activity types index page' do

    it 'links from activity categories page and shows empty page' do
      visit activity_categories_path
      click_on 'Search'

      expect(page).to have_content('Find activities')
      expect(page).not_to have_content('No activities found')
    end

    it 'links to activity categories page' do
      visit activity_types_path
      click_on 'All activities'

      expect(page).to have_content('Explore energy saving activities')
    end

    it 'shows search results' do
      visit activity_types_path
      fill_in 'query', with: 'foo'
      click_on 'Search'

      expect(page).to have_content(activity_type_1.name)
    end

    it 'shows no results' do
      visit activity_types_path
      fill_in 'query', with: 'blah'
      click_on 'Search'

      expect(page).to have_content('No activities found')
    end
  end
end
