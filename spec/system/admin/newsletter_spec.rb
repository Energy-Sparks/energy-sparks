require 'rails_helper'

describe 'Newsletter managment', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      within '.application' do
        click_on 'Newsletters'
      end
    end

    it 'allows the user to create, edit and delete a newsletter type' do
      url = 'https://sausage-dogs-and-draught-excluders.com'
      title = 'Save energy with a sausage dog'
      new_title = 'Save energy without a sausage dog'

      click_on 'New Newsletter'
      fill_in 'Title', with: title
      click_on 'Create Newsletter'
      expect(page).to have_content('blank')
      fill_in 'Url', with: url
      attach_file("Image", Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
      click_on 'Create Newsletter'
      expect(page).to have_content url

      click_on 'Edit'
      fill_in 'Title', with: new_title
      click_on 'Update Newsletter'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Newsletter was successfully destroyed.')
    end
  end
end
