require 'rails_helper'

RSpec.describe 'Solar pv areas', type: :system do
  let!(:admin)                  { create(:admin) }
  let(:title)                   { 'Lights out for darker skies' }
  let(:description)             { 'Better for badgers' }
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Solar PV Areas'
    end

    it 'can create a new area' do
      expect(page).to have_content("There are no Solar PV Areas")

      click_on 'New Solar PV Area'

      fill_in 'Title', with: title
      fill_in 'Description', with: description
      fill_in 'Latitude', with: latitude
      fill_in 'Longitude', with: longitude

      expect { click_on 'Create' }.to change { SolarPvTuosArea.count }.by(1)

      expect(page).to have_content("New Solar PV Area created")
      expect(page).to have_content('Solar PV Areas')
      expect(page).to have_content title
      expect(page).to have_content description
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    it 'checks for valid fields' do
      click_on 'New Solar PV Area'

      fill_in 'Title', with: title
      fill_in 'Description', with: description
      fill_in 'Latitude', with: latitude

      expect { click_on 'Create' }.to change { SolarPvTuosArea.count }.by(0)

      expect(page).to have_content("can't be blank")

      fill_in 'Longitude', with: longitude
      expect { click_on 'Create' }.to change { SolarPvTuosArea.count }.by(1)

      expect(page).to have_content('Solar PV Areas')
      expect(page).to have_content title
      expect(page).to have_content description
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    context 'with an existing area' do

      let!(:area) { SolarPvTuosArea.create!(title: title, description: description, latitude: latitude, longitude: longitude) }

      before(:each) do
        click_on 'Manage'
        click_on 'Admin'
        click_on 'Solar PV Areas'

        expect(SolarPvTuosArea.count).to be 1
        expect(page).to have_content('Solar PV Areas')
        expect(page).to have_content title
        expect(page).to have_content description
        expect(page).to have_content latitude
        expect(page).to have_content longitude
      end

      it 'can be edited' do
        expect(SolarPvTuosArea.count).to be 1
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999
        fill_in 'Latitude', with: new_latitude
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("Solar PV Area was updated")

        expect(page).to have_content('Solar PV Areas')
        expect(page).to have_content title
        expect(page).to have_content description
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
      end

      it 'checks for valid fields on update' do
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999

        fill_in 'Latitude', with: ''
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("can't be blank")

        fill_in 'Latitude', with: new_latitude

        click_on 'Update'
        expect(page).to have_content("Solar PV Area was updated")

        expect(page).to have_content('Solar PV Areas')
        expect(page).to have_content title
        expect(page).to have_content description
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
      end
    end
  end
end
