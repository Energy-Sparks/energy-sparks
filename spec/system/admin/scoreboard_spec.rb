require 'rails_helper'

RSpec.describe 'scoreboards', :scoreboards, type: :system do

  let!(:admin)                  { create(:admin) }
  let!(:regional_calendar)      { create(:regional_calendar, national_title: 'Scotland') }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
    end

    it 'can add a new scoreboard with validation' do
      visit admin_scoreboards_path
      click_on 'New Scoreboard'
      click_on 'Create Scoreboard'
      expect(page).to have_content("can't be blank")

      fill_in 'Name', with: 'BANES and Frome'
      fill_in 'Description', with: 'A collection of schools'
      select 'Scotland', from: 'Academic year calendar'
      click_on 'Create Scoreboard'

      scoreboard = Scoreboard.where(name: 'BANES and Frome').first
      expect(scoreboard.academic_year_calendar).to eq(regional_calendar.based_on)
    end

    it 'can edit a scoreboard' do
      scoreboard = create(:scoreboard, name: 'BANES and Frome')
      visit admin_scoreboards_path
      click_on 'Edit'
      fill_in 'Name', with: 'BANES Only'
      click_on 'Update Scoreboard'

      scoreboard.reload
      expect(scoreboard.name).to eq('BANES Only')
    end

    it 'can delete a scoreboard' do
      scoreboard = create(:scoreboard, name: 'BANES and Frome')
      visit admin_scoreboards_path

      expect {
        click_on 'Delete'
      }.to change{Scoreboard.count}.from(1).to(0)

      expect(page).to have_content('There are no Scoreboards')
    end
  end

end
