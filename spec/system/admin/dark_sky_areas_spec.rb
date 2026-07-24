require 'rails_helper'

RSpec.describe 'Dark sky areas', type: :system do
  let!(:admin)                  { create(:admin) }
  let(:title)                   { 'Lights out for darker skies' }
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }
  let(:back_fill_years)         { 5 }

  describe 'when logged in' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Weather Stations'
      click_on 'Dark Sky Areas'
    end

    context 'with an existing dark sky area' do
      let!(:area) { DarkSkyArea.create!(title: title, latitude: latitude, longitude: longitude) }

      before do
        click_on 'Manage'
        click_on 'Admin'
        click_on 'Weather Stations'
        click_on 'Dark Sky Areas'
      end

      it 'can be viewed' do
        expect(page).to have_text('Dark Sky Areas')
        expect(page).to have_text title
        expect(page).to have_text latitude
        expect(page).to have_text longitude
        expect(page).to have_text('Report')
        expect(page).to have_text('CSV')
      end
    end
  end
end
