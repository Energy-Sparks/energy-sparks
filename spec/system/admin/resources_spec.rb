require 'rails_helper'

describe 'Resources', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Resources'
    end

    it 'allows the user to create, edit and delete a resource' do
      title = 'Lights activity sheet'
      new_title = 'Switching off activity sheet'

      click_on 'New Resource'
      fill_in_trix with: 'Helps students understand energy saving'
      click_on 'Create Resource'
      expect(page).to have_content('blank')
      fill_in 'Title', with: title
      attach_file("File", Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
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
