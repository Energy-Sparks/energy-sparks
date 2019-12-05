require 'rails_helper'

RSpec.describe "meter attribute management", :meters, type: :system do

  let!(:school_group)  { create(:school_group, name: 'BANES') }
  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create_active_school(name: school_name, school_group: school_group) }
  let!(:admin)        { create(:admin)}
  let!(:gas_meter)    { create :gas_meter, name: 'Gas meter', school: school }

  context 'as admin' do

    before(:each) do
      sign_in(admin)
      visit school_path(school)
    end

    it 'allow the admin to manage the meter attributes' do
      click_on 'Manage meters'
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

    it 'allow the admin to manage school meter attributes' do
      click_on 'Manage school'
      click_on 'Meter attributes'
      select 'Function > Switch', from: 'type'
      click_on 'New attribute'

      select 'gas', from: 'Meter type'
      select 'hotwater_only', from: 'attribute_root'

      click_on 'Create'

      expect(school.meter_attributes.size).to eq(1)
      expect{ school.meter_attributes.first.to_analytics }.to_not raise_error
      expect(school.meter_attributes.first.to_analytics.to_s).to include('hotwater_only')


      click_on 'Edit'

      select 'kitchen_only', from: 'attribute_root'

      click_on 'Update'

      school.reload
      expect(school.meter_attributes.first.to_analytics.to_s).to include('kitchen_only')

      click_on 'Delete'
      expect(school.meter_attributes.size).to eq(0)

    end

    it 'allow the admin to manage school group meter attributes' do
      click_on 'Manage'
      click_on 'School Groups'
      click_on 'Meter attributes'
      select 'Tariff', from: 'type'
      click_on 'New attribute'

      select 'electricity', from: 'Meter type'
      select 'economy_7', from: 'Type'

      click_on 'Create'

      expect(school_group.meter_attributes.size).to eq(1)
      expect{ school_group.meter_attributes.first.to_analytics }.to_not raise_error
      expect(school_group.meter_attributes.first.to_analytics.to_s).to include('economy_7')


      click_on 'Edit'

      select 'gas', from: 'type'

      click_on 'Update'

      school_group.reload
      expect(school_group.meter_attributes.first.meter_type).to eq('gas')

      click_on 'Delete'
      expect(school_group.meter_attributes.size).to eq(0)

    end
  end
end
