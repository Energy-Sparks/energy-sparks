require 'rails_helper'

RSpec.describe 'school groups', :school_groups, type: :system do

  let!(:admin)                { create(:admin) }
  let!(:scoreboard)           { create(:scoreboard, name: 'BANES and Frome') }
  let!(:dark_sky_weather_area) { create(:dark_sky_area, title: 'BANES dark sky weather') }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    it 'can add a new school group with validation' do
      click_on 'Edit School Groups'
      click_on 'New School group'
      click_on 'Create School group'
      expect(page).to have_content("Name can't be blank")

      fill_in 'Name', with: 'BANES'
      fill_in 'Description', with: 'Bath & North East Somerset'
      select 'BANES and Frome', from: 'Default scoreboard'
      select 'BANES dark sky weather', from: 'Default Dark Sky Weather Data Feed Area'

      click_on 'Create School group'

      expect(SchoolGroup.where(name: 'BANES').count).to eq(1)
    end

    it 'can edit a school group' do
      school_group = create(:school_group, name: 'BANES')
      click_on 'Edit School Groups'
      click_on 'Edit'
      fill_in 'Name', with: 'B & NES'
      click_on 'Update School group'

      school_group.reload
      expect(school_group.name).to eq('B & NES')
    end

    it 'can add a partner to the group'
    it 'can add multiple partners to the group'

    it 'can delete a school group' do
      school_group = create(:school_group)
      click_on 'Edit School Groups'

      expect {
        click_on 'Delete'
      }.to change{SchoolGroup.count}.from(1).to(0)
      expect(page).to have_content('There are no School groups')
    end
  end

end
