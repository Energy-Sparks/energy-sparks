require 'rails_helper'

describe 'CADs', type: :system do
  let!(:school)           { create_active_school(name: 'Big School')}
  let!(:admin)            { create(:admin) }

  context 'as an admin', with_feature: :new_manage_school_pages do
    before do
      sign_in(admin)
      visit settings_school_path(school)
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
      fill_in 'Maximum power (kW)', with: '5.5'
      fill_in 'Refresh interval (seconds)', with: '10'
      check 'Test mode'
      click_button 'Save'
      expect(page).to have_content('CAD was successfully updated')
      expect(school.cads.count).to eq(1)
      expect(Cad.last.name).to eq('My First CAD')
      expect(Cad.last.max_power).to eq(5.5)
      expect(Cad.last.test_mode).to be_truthy
      click_link 'Delete'
      expect(page).to have_content('CAD was successfully deleted')
      expect(school.cads.count).to eq(0)
    end
  end
end
