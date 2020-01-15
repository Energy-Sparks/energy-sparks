require 'rails_helper'

RSpec.describe 'scoreboards', :scoreboards, type: :system do

  let!(:scoreboard)   { create(:scoreboard, name: 'Super scoreboard')}
  let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }
  let!(:user)         { create(:staff, school: school)}

  describe 'when logged in' do
    before(:each) do
      sign_in(user)
    end

    it 'can add a new scoreboard with validation' do
      visit schools_path
      click_on 'View scoreboard'
      expect(page).to have_content('Super scoreboard')
    end
  end
end
