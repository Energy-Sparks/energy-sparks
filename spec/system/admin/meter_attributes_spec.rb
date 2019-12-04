require 'rails_helper'

RSpec.describe "meter attribute management", :meters, type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create_active_school(name: school_name)}
  let!(:admin)        { create(:admin)}
  let!(:gas_meter)    { create :gas_meter, name: 'Gas meter', school: school }

  context 'as admin' do

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on('Schools')
      click_on('Oldfield Park Infants')
      click_on 'Manage meters'
    end

    it 'allow the admin to manage the meter attributes' do
      click_on 'Details'
      select 'Heating model', from: 'type'
      click_on 'New attribute'

      fill_in 'Max summer daily heating kwh', with: 800

      click_on 'Create'

      expect(gas_meter.meter_attributes.size).to eq(1)
      expect{ gas_meter.meter_attributes.first.to_analytics }.to_not raise_error
      expect(gas_meter.meter_attributes.first.to_analytics.to_s).to include('800')


      within '#database-meter-attributes-content' do
        click_on 'Edit'
      end

      fill_in 'Max summer daily heating kwh', with: 200

      click_on 'Update'

      gas_meter.reload
      expect(gas_meter.meter_attributes.first.to_analytics.to_s).to include('200')

      within '#database-meter-attributes-content' do
        click_on 'Delete'
      end
      expect(gas_meter.meter_attributes.size).to eq(0)

    end
  end
end
