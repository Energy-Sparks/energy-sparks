require 'rails_helper'

describe 'Resources', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      within '.application' do
        click_on 'Resources'
      end
    end

    it 'allows the user to create, edit and delete a resource type' do
      title = 'Documents'
      new_title = 'Docs'

      click_on 'Manage resource types'
      click_on 'New Resource type'
      click_on 'Create Resource file type'
      expect(page).to have_content('blank')
      fill_in 'Title', with: title
      fill_in 'Position', with: 1
      click_on 'Create Resource file type'
      expect(page).to have_content title
      expect(ResourceFileType.where(title: title).count).to eq(1)

      click_on 'Edit'
      fill_in 'Title', with: new_title
      click_on 'Update Resource file type'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Resource type was successfully destroyed.')
      expect(ResourceFileType.count).to eq(0)
    end

    it 'allows the user to create, edit and delete a resource' do
      create(:resource_file_type, title: 'Document')

      title = 'Lights activity sheet'
      new_title = 'Switching off activity sheet'

      click_on 'New Resource'
      fill_in_trix with: 'Helps students understand energy saving'
      click_on 'Create Resource'
      expect(page).to have_content('blank')
      fill_in 'Title', with: title
      attach_file("File", Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
      select 'Document', from: 'Type'
      click_on 'Create Resource'
      expect(page).to have_content title

      click_on 'Edit'
      fill_in 'Title', with: new_title
      click_on 'Update Resource'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Resource was successfully destroyed.')
      expect(ResourceFile.count).to eq(0)
    end
  end
end
