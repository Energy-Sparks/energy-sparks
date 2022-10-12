require 'rails_helper'

describe 'school groups', :school_groups, type: :system do

  let!(:user)                  { create(:user) }
  let!(:scoreboard)            { create(:scoreboard, name: 'BANES and Frome') }
  let!(:dark_sky_weather_area) { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let!(:school_group)          { create(:school_group, public: public) }
  let(:public)                 { true }
  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20) }
  let!(:school_admin)          { create(:school_admin, school: school_1) }

  describe 'when not logged in' do
    it 'does show a specific group' do
      visit school_group_path(school_group)
      expect(page).to have_content(school_1.name)
      expect(page).to have_content(school_2.name)
    end

    it 'includes data attribute' do
      visit school_group_path(school_group)

      # el = page.find('div[id="runtime"]')['data-value']
      # p usage

      # expect(page).to have_selector('div[data-school-group-id="' + school_group.id.to_s + '"]')
      expect(page).to have_selector("div[data-school-group-id='#{school_group.id}']")
    end

    context 'when group is public' do
      it 'shows compare link' do
        visit school_group_path(school_group)
        expect(page).to have_link("Compare schools")
      end

    end
    context 'when group is private' do
      let(:public)    { false }

      it 'doesnt show compare link' do
        visit school_group_path(school_group)
        within('.application') do
          expect(page).to_not have_link("Compare schools")
        end
      end
    end
  end

  describe 'when logged in as school admin' do
    before(:each) do
      sign_in(school_admin)
    end
    it 'shows compare link' do
      visit school_group_path(school_group)
      expect(page).to have_link("Compare schools")
    end
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(user)
    end
    context 'when group is public' do
      it 'shows compare link' do
        visit school_group_path(school_group)
        expect(page).to have_link("Compare schools")
      end
    end
    context 'when group is private' do
      it 'doesnt show compare link' do
        visit school_group_path(school_group)
        expect(page).to have_link("Compare schools")
      end
    end
  end
end
