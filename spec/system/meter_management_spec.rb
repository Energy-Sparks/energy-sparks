require 'rails_helper'

RSpec.describe "meter management", :meters, type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create_active_school(name: school_name)}
  let!(:admin)        { create(:admin)}
  let!(:teacher)      { create(:staff)}
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

    context 'when the school has a DCC meter' do
      let!(:meter) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }

      it 'the meter inventory button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Inventory')
      end

      it 'the tariff report button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Tariff Report')
      end

      it 'the attributes button is not shown' do
        click_on 'Manage meters'
        click_on 'Details'
        expect(page).not_to have_button('Attributes')
      end

    end
  end

  context 'as teacher' do
    before(:each) do
      sign_in(teacher)
      visit school_meters_path(school)

    end

    it 'does not see things it should not' do
      expect(page).to_not have_content('Delete')
      expect(page).to_not have_content('Create Meter')
      expect(page).to_not have_content('Activate')
      expect(page).to_not have_content('Deactivate')
    end
  end

  context 'as admin' do

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on('Schools')
      click_on('Oldfield Park Infants')
    end

    context 'when the school has a DCC meter' do
      let!(:meter) { create(:electricity_meter, dcc_meter: true, name: 'Electricity meter', school: school, mpan_mprn: 1234567890123 ) }
      let!(:data_api) { double(find: true, inventory: {device_id: 123999}, elements: [1]) }

      it 'the meter inventory button can be shown' do
        allow_any_instance_of(Amr::N3rgyApiFactory).to receive(:data_api).with(meter).and_return(data_api)
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Inventory'
        expect(page).to have_content('device_id')
        expect(page).to have_content('123999')
      end

      it 'the tariff report can be shown' do
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Tariff Report'
        expect(page).to have_content("Standing charges")
      end

      it 'the single meter attributes view can be shown' do
        click_on 'Manage meters'
        click_on 'Details'
        click_on 'Attributes'
        expect(page).to have_content("Individual Meter attributes")
      end

      it 'the dcc checkboxes and status are shown on the edit form' do
        allow_any_instance_of(Amr::N3rgyApiFactory).to receive(:data_api).with(meter).and_return(data_api)
        click_on 'Manage meters'
        click_on 'Edit'
        expect(page).to have_content('This meter is available via n3rgy')
      end
    end

    it 'allows adding of meters from the management page with validation' do
      click_on('Manage meters')

      click_on 'Create Meter'
      expect(page).to have_content("Meter type can't be blank")

      fill_in 'Meter Point Number', with: '123543'
      fill_in 'Name', with: 'Gas'
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

      before(:each) do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
      end

      before(:each) {
        click_on 'Manage meters'
      }

      it 'allows deletion of inactive meters' do
        click_on 'Deactivate'
        click_on 'Delete'
        expect(school.meters.count).to eq(0)
      end
    end

    context 'when checking target data' do
      context 'and there is enough' do
        before(:each) do
          allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
          click_on 'Manage meters'
        end

        it 'should say' do
          expect(page).to have_content("This school has enough data for at least one fuel type to generate targets")
        end
        it 'should link to detail' do
          expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
        end
      end

      context 'and there is not enough' do
        before(:each) do
          allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)
          click_on 'Manage meters'
        end

        it 'should say' do
          expect(page).to have_content("This school does not have enough data to generate targets")
        end

        it 'should link to detail' do
          expect(page).to have_link("View target data", href: admin_school_target_data_path(school))
        end
      end
    end

  end
end
