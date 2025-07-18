require 'rails_helper'

describe 'school switcher', type: :system do
  let!(:school_1)              { create(:school, number_of_pupils: 10) }
  let!(:school_2)              { create(:school, number_of_pupils: 20) }
  let!(:user)                  { create(:school_admin, school: school_1, cluster_schools: [school_2]) }

  describe 'when logged in' do
    before do
      sign_in(user)
    end

    it 'shows a summary of the schools in the group' do
      visit school_path(school_1)
      expect(page).to have_content(school_1.name)
      click_on('My schools')
      click_on(school_2.name)
      expect(page).to have_content(school_2.name)
      expect(user.reload.cluster_schools).to match_array([school_1, school_2])
    end
  end
end
