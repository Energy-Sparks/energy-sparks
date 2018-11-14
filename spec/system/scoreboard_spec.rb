require 'rails_helper'

RSpec.describe 'scoreboards', type: :system do

  let!(:admin) { create(:user, role: 'admin')}

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
    end

    it 'can add a new scoreboard with validation' do
      visit scoreboards_path
      click_on 'New Scoreboard'
      click_on 'Create Scoreboard'
      expect(page).to have_content("Name can't be blank")

      fill_in 'Name', with: 'BANES and Frome'
      fill_in 'Description', with: 'A collection of schools'
      click_on 'Create Scoreboard'

      expect(Scoreboard.where(name: 'BANES and Frome').count).to eq(1)
    end

    it 'can edit a scoreboard' do
      scoreboard = create(:scoreboard, name: 'BANES and Frome')
      visit scoreboards_path
      click_on 'Edit'
      fill_in 'Name', with: 'BANES Only'
      click_on 'Update Scoreboard'

      scoreboard.reload
      expect(scoreboard.name).to eq('BANES Only')
    end

    it 'can delete a scoreboard when it is not assigned to a group' do
      scoreboard = create(:scoreboard, name: 'BANES and Frome')
      group = create(:school_group, scoreboard: scoreboard)
      visit scoreboards_path
      expect {
        click_on 'Delete'
      }.to_not change{Scoreboard.count}
      expect(page).to have_content("Scoreboard still has associated school")

      group.update!(scoreboard: nil)

      expect {
        click_on 'Delete'
      }.to change{Scoreboard.count}.from(1).to(0)

      expect(page).to have_content('There are no Scoreboards')
    end
  end

end
