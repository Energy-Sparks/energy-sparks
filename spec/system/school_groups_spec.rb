require 'rails_helper'

describe 'school groups', :school_groups, type: :system do

  let!(:user)                  { create(:user) }
  let!(:admin)                 { create(:admin) }
  let!(:scoreboard)            { create(:scoreboard, name: 'BANES and Frome') }
  let!(:dark_sky_weather_area) { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let!(:school_group)          { create(:school_group) }
  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20) }

  describe 'when not logged in' do
    it 'does not show a summary of groups' do
      visit school_groups_path
      expect(page).not_to have_content(school_group.name)
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(user)
    end

    # it 'show a summary of groups' do
    #   visit school_groups_path
    #   expect(page).to have_content(school_group.name)
    #   expect(page).to have_content(30)
    # end

    it 'shows a summary of the schools in the group' do
      visit school_group_path(school_group)
      expect(page).to have_content(school_1.name)
      expect(page).to have_content(school_2.name)
    end
  end

  describe 'when logged in as admin' do
    before(:each) do
      sign_in(admin)
    end

    it 'show a summary of groups' do
      visit school_groups_path
      expect(page).to have_content(school_group.name)
      expect(page).to have_content(30)
    end

    it 'shows a summary of the schools in the group' do
      visit school_groups_path
      click_on(school_group.name)
      expect(page).to have_content(school_1.name)
      expect(page).to have_content(school_2.name)
    end
  end
end
