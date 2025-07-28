# frozen_string_literal: true

require 'rails_helper'

describe 'School group engagement' do
  let(:school) { create(:school, :with_school_group) }

  context 'when not logged in' do
    it do
      visit school_group_school_engagement_index_path(school.school_group)
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end

  context 'when signed in' do
    before do
      sign_in(create(:admin))
      create(:school, data_enabled: false, school_group: school.school_group)
      visit school_group_school_engagement_index_path(school.school_group)
    end

    it 'displays title' do
      expect(page).to have_title('School engagement')
      expect(page).to have_content('School engagement')
    end

    it 'displays the table' do
      expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
        [
          ['School', 'School type', 'Activities', 'Actions', 'Programmes', 'Energy saving target',
           'Completed transport survey', 'Recorded temperatures', 'Received an audit', 'Active users', 'Last visit'],
          [school.name, 'Primary', '0', '0', '0', 'No', 'No', 'No', 'No', '0', '']
        ]
      )
    end

    it 'allows csv download' do
      click_on 'Download as CSV'
      expect(page.response_headers['content-type']).to eq('text/csv')
      expect(body).to \
        eq('School,School type,Activities,Actions,Programmes,Energy saving target,Completed transport survey,' \
           "Recorded temperatures,Received an audit,Active users,Last visit\n" \
           "#{school.name},Primary,0,0,0,No,No,No,No,0,\n")
    end
  end
end
