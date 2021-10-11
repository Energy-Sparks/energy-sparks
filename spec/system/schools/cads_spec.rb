require 'rails_helper'

describe 'CADs', type: :system do

  let!(:school)           { create_active_school(name: "Big School")}
  let!(:school_admin)     { create(:school_admin, school: school) }

  context 'as a school admin' do

    before(:each) do
      sign_in(school_admin)
      visit root_path
    end

    it 'allows CAD to be created, edited, deleted' do
      click_link 'Manage CADs'
      expect(page).to have_content('Manage CADs')
      click_link 'Add CAD'
      fill_in 'Name', with: 'My First CAD'
      fill_in 'Device identifier', with: '1234-5678'
      click_button 'Save'
      expect(page).to have_content('CAD was successfully created')
      expect(page).to have_content('My First CAD')
      click_link 'Edit'
      fill_in 'Max power', with: '5000'
      fill_in 'Refresh interval', with: '10000'
      check 'Test mode'
      click_button 'Save'
      expect(page).to have_content('CAD was successfully updated')
      expect(school.cads.count).to eq(1)
      expect(Cad.last.name).to eq('My First CAD')
      expect(Cad.last.test_mode).to be_truthy
      click_link 'Delete'
      expect(page).to have_content('CAD was successfully deleted')
      expect(school.cads.count).to eq(0)
    end
  end
end
