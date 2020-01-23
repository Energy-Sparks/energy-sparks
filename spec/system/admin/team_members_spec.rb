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

      click_on 'New team member'
      fill_in 'Description', with: 'Energy Expert'
      fill_in 'Position', with: '1'
      click_on 'Create Team member'

      expect(page).to have_content('blank')
      fill_in 'Title', with: title

      attach_file("Image", Rails.root + "spec/fixtures/images/banes.png")
      click_on 'Create Team member'
      expect(page).to have_content title

      click_on 'Edit'
      fill_in 'Title', with: new_title
      click_on 'Update Team member'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Team member was successfully destroyed.')
    end
  end
end


#
#  created_at  :datetime         not null
#  description :text
#  id          :bigint(8)        not null, primary key
#  position    :integer          default(0), not null
#  title       :string           not null
#  updated_at  :datetime         not null
#