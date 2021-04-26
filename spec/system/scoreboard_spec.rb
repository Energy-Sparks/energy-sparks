require 'rails_helper'

RSpec.describe 'scoreboards', :scoreboards, type: :system do

  let!(:scoreboard)   { create(:scoreboard, name: 'Super scoreboard')}
  let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }

  describe 'with public scoreboards' do
      it 'allows anyone to see the scoreboard' do
        visit schools_path
        click_on 'Scoreboards'
        click_on 'Super scoreboard'
        expect(page).to have_content('Super scoreboard')
        expect(page).to have_content(school.name)
      end
  end

  describe 'with private scoreboards' do
    let!(:private_scoreboard)   { create(:scoreboard, name: 'Private scoreboard', public: false)}
    let!(:other_school)       { create(:school, :with_school_group, scoreboard: private_scoreboard) }

    it 'doesnt list the scoreboard' do
      visit schools_path
      click_on 'Scoreboards'
      expect(page).to have_content('Super scoreboard')
      expect(page).to_not have_content('Private scoreboard')
    end

    it 'doesnt allow access to the private scoreboard' do
      visit scoreboard_path(private_scoreboard)
      expect(page).to have_content('You are not authorized to access this page')
    end

    describe 'when logged in as user from school linked to scoreboard' do
      let!(:user)         { create(:staff, school: other_school)}

      before(:each) do
        sign_in(user)
      end

      it 'can view the public and private boards' do
        visit schools_path
        click_on 'Scoreboards'
        expect(page).to have_content('Super scoreboard')
        expect(page).to have_content('Private scoreboard')
        click_on 'Private scoreboard'
        expect(page).to have_content('Private scoreboard')
        expect(page).to have_content(other_school.name)
      end

    end

  end

end
