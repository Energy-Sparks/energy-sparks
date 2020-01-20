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
    end

    it 'allow the admin to manage the meter attributes' do
      visit school_path(school)
      click_on 'Manage school'
      click_on 'Meter attributes'
      select 'Heating model', from: 'type'
      click_on 'New attribute'

      fill_in 'Max summer daily heating kwh', with: 800

      click_on 'Create'

      expect(gas_meter.meter_attributes.size).to eq(1)
      attribute = gas_meter.meter_attributes.first
      expect{ attribute.to_analytics }.to_not raise_error
      expect(attribute.to_analytics.to_s).to include('800')


      within '#database-meter-attributes-content' do
        click_on 'Edit'
      end

      fill_in 'Max summer daily heating kwh', with: 200

      click_on 'Update'

      gas_meter.reload
      new_attribute = gas_meter.meter_attributes.active.first
      expect(new_attribute.to_analytics.to_s).to include('200')
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      within '#database-meter-attributes-content' do
        click_on 'Delete'
      end
      expect(gas_meter.meter_attributes.active.size).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)

    end

    it 'allow the admin to manage school meter attributes' do
      visit school_path(school)
      click_on 'Manage school'
      click_on 'Meter attributes'
      click_on 'School-wide attributes'
      select 'Function > Switch', from: 'type'
      click_on 'New attribute'

      check 'gas'
      select 'hotwater_only', from: 'attribute_root'

      click_on 'Create'

      expect(school.meter_attributes.size).to eq(1)
      attribute = school.meter_attributes.first
      expect{ attribute.to_analytics }.to_not raise_error
      expect(attribute.to_analytics.to_s).to include('hotwater_only')


      click_on 'Edit'

      select 'kitchen_only', from: 'attribute_root'

      click_on 'Update'

      school.reload
      new_attribute = school.meter_attributes.active.first
      expect(new_attribute.to_analytics.to_s).to include('kitchen_only')
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      click_on 'Delete'
      expect(school.meter_attributes.active.size).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)

    end

    it 'allow the admin to manage school group meter attributes' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'School Groups'
      click_on 'Meter attributes'
      select 'Tariff', from: 'type'
      click_on 'New attribute'

      check 'electricity'
      select 'economy_7', from: 'Type'

      click_on 'Create'

      expect(school_group.meter_attributes.size).to eq(1)
      attribute = school_group.meter_attributes.first
      expect{ attribute.to_analytics }.to_not raise_error
      expect(attribute.to_analytics.to_s).to include('economy_7')


      click_on 'Edit'

      check 'gas'
      uncheck 'electricity'

      click_on 'Update'

      school_group.reload
      new_attribute = school_group.meter_attributes.active.first
      expect(new_attribute.selected_meter_types).to eq([:gas])
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      click_on 'Delete'
      expect(school_group.meter_attributes.active.size).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)

    end

    it 'allow the admin to download all meter attributes' do
      meter_attribute = create(:meter_attribute)
      visit root_path
      click_on 'Manage'
      click_on 'Reports'

      click_on 'Download meter attributes'

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(YAML.load(page.source)[meter_attribute.meter.school.urn][:meter_attributes][meter_attribute.meter.mpan_mprn][:function]).to eq([:heating_only])
    end

    it 'allow the admin to manage global meter attributes' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Global Meter Attributes'
      select 'Tariff', from: 'type'
      click_on 'New attribute'

      check 'electricity'
      select 'economy_7', from: 'Type'

      click_on 'Create'

      expect(GlobalMeterAttribute.count).to eq(1)
      attribute = GlobalMeterAttribute.first
      expect{ attribute.to_analytics }.to_not raise_error
      expect(attribute.to_analytics.to_s).to include('economy_7')


      click_on 'Edit'

      check 'gas'
      uncheck 'electricity'

      click_on 'Update'

      new_attribute = GlobalMeterAttribute.active.first
      expect(new_attribute.selected_meter_types).to eq([:gas])
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      click_on 'Delete'
      expect(GlobalMeterAttribute.active.count).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)

    end
  end
end
