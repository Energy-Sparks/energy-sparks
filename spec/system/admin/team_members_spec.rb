require 'rails_helper'

describe 'Team members', type: :system do
  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Team members'
    end

    it 'allows the user to create, edit and delete a team member' do
      title = 'John Smith'
      new_title = 'Joe Bloggs'
      profile = 'World renowned expert'

      click_on 'New team member'
      fill_in 'Job description', with: 'Energy Expert'
      fill_in 'Position', with: '1'
      click_on 'Create Team member'

      expect(page).to have_content('blank')
      fill_in 'Name', with: title
      # for some reason, this is filling the profile field
      # fill_in_trix with: profile

      attach_file("Image", Rails.root + "spec/fixtures/images/banes.png")
      click_on 'Create Team member'
      expect(page).to have_content 'Team member was successfully created'
      expect(page).to have_content title

      click_on 'Edit'
      fill_in 'Name', with: new_title
      click_on 'Update Team member'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Team member was successfully destroyed.')
    end
  end
end

