require 'rails_helper'

RSpec.describe 'school adult dashboard', type: :system do
  let(:school_name)         { 'Oldfield Park Infants' }
  let!(:school_group)       { create(:school_group, name: 'School Group')}
  let!(:school)             { create(:school, name: school_name, latitude: 51.34062, longitude: -2.30142)}

  context 'with invisible school' do
    let!(:school_invisible)       { create(:school, name: 'Invisible School', visible: false, school_group: school_group)}

    context 'as guest user' do
      it 'prompts user to login when viewing' do
        visit school_path(school_invisible)
        expect(page.has_content?('You are not authorized to access this page')).to be true
      end

      context 'when also not data enabled' do
        it 'does not raise a double render error' do
          school_invisible.update(data_enabled: false)
          visit school_path(school_invisible)
          expect(page.has_content?('You are not authorized to access this page')).to be true
        end
      end
    end

    context 'as admin' do
      let!(:admin) { create(:admin)}

      before do
        sign_in(admin)
        visit root_path
        within('#our-schools') do
          click_on('View schools')
        end
      end

      it 'shows school' do
        visit school_path(school_invisible)
        expect(page.has_link?('Pupil dashboard')).to be true
        expect(page.has_content?(school_invisible.name)).to be true
      end
    end
  end

  context 'school with non-public data' do
    let!(:non_public_school) { create(:school, name: 'Non-public School', visible: true, data_sharing: :within_group, school_group: school_group)}

    context 'as a guest user' do
      it 'is listed on school page' do
        visit schools_path(letter: non_public_school.name.first.upcase)
        expect(page.has_content?(non_public_school.name)).to be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content?('This school has disabled public access')).to be true
      end
    end

    context 'as staff' do
      let!(:school_admin) { create(:school_admin, school: non_public_school) }

      before do
        sign_in(school_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link('Compare schools')
      end

      it 'redirects away user from the /private page' do
        visit school_private_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link('Compare schools')
      end
    end

    context 'as a user in the same school group' do
      let!(:school_in_same_group)   { create(:school, name: 'Same Group School', visible: true, school_group: school_group)}
      let!(:other_admin)            { create(:school_admin, school: school_in_same_group) }

      before do
        sign_in(other_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link('Compare schools')
      end
    end

    context 'as a unrelated school user' do
      let!(:other_admin)    { create(:school_admin) }

      before do
        sign_in(other_admin)
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content?('This school has disabled public access')).to be true
      end
    end
  end
end
