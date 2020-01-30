require 'rails_helper'

RSpec.describe "meter management", :meters, type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create_active_school(name: school_name)}
  let!(:admin)        { create(:admin)}
  let!(:school_admin) { create(:school_admin, school_id: school.id) }

  context 'as school admin' do
    before(:each) do
      sign_in(school_admin)
      visit root_path
    end

    context 'when the school has a meter with no readings' do
      let!(:gas_meter) { create :gas_meter, name: 'Gas meter', school: school }

      it 'allows deletion of inactive meters' do
        click_on 'Manage meters'
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) { create(:electricity_meter_with_reading, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }

      it 'the meter cannot be deleted' do
        click_on 'Manage meters'
        click_on 'Deactivate'
        expect(meter.amr_data_feed_readings.count).to eq(1)
        expect(page).to have_button('Delete', disabled: true)
      end
    end
  end

  context 'as admin' do

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on('Schools')
      click_on('Oldfield Park Infants')
    end

    it 'allows adding of meters from the management page with validation' do
      click_on('Manage meters')

      click_on 'Create Meter'
      expect(page).to have_content("Meter type can't be blank")

      fill_in 'Meter Point Number', with: '123543'
      fill_in 'Meter Name', with: 'Gas'
      choose 'Gas'
      click_on 'Create Meter'

      expect(school.meters.count).to eq(1)
      expect(school.meters.first.mpan_mprn).to eq(123543)
    end

    context 'when the school has a meter' do

      let!(:gas_meter) { create :gas_meter, name: 'Gas meter', school: school }

      before(:each) {
        click_on 'Manage meters'
      }

      it 'allows editing' do
        click_on 'Edit'
        fill_in 'Name', with: 'Natural Gas Meter'
        click_on 'Update Meter'
        gas_meter.reload
        expect(gas_meter.name).to eq('Natural Gas Meter')
      end

      it 'allows deactivation and reactivation of a meter' do
        click_on 'Deactivate'

        gas_meter.reload
        expect(gas_meter.active).to eq(false)

        click_on 'Activate'
        gas_meter.reload
        expect(gas_meter.active).to eq(true)
      end

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end

      it 'does not show the CSV download button if no readings' do
        expect(gas_meter.amr_validated_readings.empty?).to be true
        expect(page).to_not have_content('CSV')
      end
    end

    context 'when the school has a meter with readings' do
      let!(:meter) { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

      before(:each) {
        click_on 'Manage meters'
      }

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end
  end
end
