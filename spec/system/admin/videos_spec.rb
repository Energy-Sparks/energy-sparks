require 'rails_helper'

describe 'Videos', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing videos' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      within '.application' do
        click_on 'Videos'
      end
    end

    it 'allows the user to create, edit and delete a video' do
#      create(:video, youtube_id: "abcdef", title: 'My video')

      title = 'My title'
      new_title = 'The edited title'

      click_on 'New Video'
      fill_in 'Title', with: title
      click_on 'Create Video'
      expect(page).to have_content('blank')
      fill_in 'Youtube', with: "12345"

      click_on 'Create Video'
      expect(page).to have_content title

      click_on 'Edit'
      fill_in 'Title', with: new_title
      click_on 'Update Video'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Video was successfully deleted.')
      expect(Video.count).to eq(0)
    end

  end
end
