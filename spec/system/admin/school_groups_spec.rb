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
      uncheck 'Public'
      click_on 'Update School group'

      school_group.reload
      expect(school_group.name).to eq('B & NES')
      expect(school_group).to_not be_public
    end

    it 'can delete a school group' do
      school_group = create(:school_group)
      click_on 'Edit School Groups'

      expect {
        click_on 'Delete'
      }.to change{SchoolGroup.count}.from(1).to(0)
      expect(page).to have_content('There are no School groups')
    end
  end

  context "with partners" do

    let!(:partner_1)         { create(:partner) }
    let!(:partner_2)         { create(:partner) }
    let!(:partner_3)         { create(:partner) }
    let!(:school_group)      { create(:school_group, name: 'BANES') }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Edit School Groups'
    end

    it 'has a partner link on the school group page' do
      click_on 'Manage Partners'
      expect(page).to have_content("BANES")
      expect(page).to have_content(partner_1.display_name)
    end

    it 'assigns partners to school groups via text box position' do
      click_on 'Manage Partners'
      expect(page.find_field(partner_1.name).value).to be_blank
      expect(page.find_field(partner_2.name).value).to be_blank
      expect(page.find_field(partner_3.name).value).to be_blank

      fill_in partner_3.name, with: '1'
      fill_in partner_2.name, with: '2'

      click_on 'Update associated partners', match: :first
      click_on 'Manage Partners'

      expect(school_group.partners).to match_array([partner_3, partner_2])
      expect(school_group.school_group_partners.first.position).to eql 1
      expect(school_group.school_group_partners.last.position).to eql 2

      fill_in partner_3.name, with: ""

      click_on 'Update associated partners', match: :first
      click_on 'Manage Partners'
      school_group.reload
      expect(school_group.partners).to match_array([partner_2])

    end

  end
end
