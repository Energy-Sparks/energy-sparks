require 'rails_helper'

describe 'Partners', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Partners', match: :first
    end

    it 'allows the user to create, edit and delete a partner' do
      click_on 'New partner'
      fill_in 'Position', with: '1'

      attach_file("Image", Rails.root + "spec/fixtures/images/sheffield.png")
      expect { click_on 'Create Partner' }.to change { Partner.count }.by(1)

      expect(page).to have_xpath("//img[contains(@src,'sheffield.png')]")

      click_on 'Edit'
      attach_file("Image", Rails.root + "spec/fixtures/images/banes.png")

      click_on 'Update Partner'
      expect(page).to have_xpath("//img[contains(@src,'banes.png')]")

      expect { click_on 'Delete' }.to change { Partner.count }.by(-1)
      expect(page).to have_content('Partner was successfully destroyed.')
    end
  end
end
