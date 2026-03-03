require 'rails_helper'

RSpec.describe 'meter attribute management', :meters, type: :system do
  let!(:school_group)       { create(:school_group, name: 'BANES') }
  let!(:school_name)        { 'Oldfield Park Infants'}
  let!(:school)             { create_active_school(name: school_name, school_group: school_group) }
  let!(:admin)              { create(:admin)}
  let!(:gas_meter)          { create :gas_meter, name: 'Gas meter', school: school }

  context 'as admin' do
    before do
      sign_in(admin)
    end

    context 'when analytics attributes are broken' do
      before do
        expect(MeterAttribute).to receive(:to_analytics).at_least(:once).and_raise(StandardError.new('There was an error'))
      end

      it 'shows broken index' do
        create(:meter_attribute, meter: gas_meter)
        visit school_path(school)
        click_on 'Meter attributes'
        expect(page).to have_content('Meter attributes for Oldfield Park Infants')
        expect(page).to have_content('There was an error')
      end

      it 'deletes broken meter attribute' do
        create(:meter_attribute, meter: gas_meter)
        visit school_path(school)
        click_on 'Meter attributes'
        click_on 'Delete'
        expect(gas_meter.reload.meter_attributes.active.count).to eq(0)
        expect(gas_meter.reload.meter_attributes.deleted.count).to eq(1)
        expect(page).to have_content('There was an error')
      end

      it 'deletes broken school attribute' do
        create(:school_meter_attribute, school: school)
        visit school_path(school)
        click_on 'Meter attributes'
        click_on 'School-wide attributes'
        click_on 'Delete'
        expect(school.reload.meter_attributes.active.count).to eq(0)
        expect(school.reload.meter_attributes.deleted.count).to eq(1)
        expect(page).to have_content('There was an error')
      end

      it 'deletes broken global meter attribute' do
        create(:global_meter_attribute)
        visit admin_path(school)
        click_on 'Global Meter Attributes'
        click_on 'Delete'
        expect(GlobalMeterAttribute.active.count).to eq(0)
        expect(GlobalMeterAttribute.deleted.count).to eq(1)
        expect(page).to have_content('There was an error')
      end
    end


    it 'is able to display a form for all meter attributes' do
      visit admin_school_single_meter_attribute_path(school, gas_meter)
      options = find('#type').all('option').collect(&:text)

      options.each do |option|
        select option, from: 'type'
        click_on 'New attribute'
        expect(page).to have_button('Create')
        visit admin_school_single_meter_attribute_path(school, gas_meter)
      end
    end

    it 'allow the admin to manage the meter attributes' do
      visit school_path(school)
      click_on 'Meter attributes'
      select 'Heating model', from: 'type'
      click_on 'New attribute'

      fill_in 'Max summer daily heating kwh', with: 800

      click_on 'Create'

      expect(gas_meter.meter_attributes.size).to eq(1)
      attribute = gas_meter.meter_attributes.first
      expect { attribute.to_analytics }.not_to raise_error
      expect(attribute.to_analytics.to_s).to include('800')


      within '#database-meter-attributes' do
        click_on 'Edit'
      end

      fill_in 'Max summer daily heating kwh', with: 200

      click_on 'Update'

      gas_meter.reload
      new_attribute = gas_meter.meter_attributes.active.first
      expect(new_attribute.to_analytics.to_s).to include('200')
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      within '#database-meter-attributes' do
        click_on 'Delete'
      end
      expect(gas_meter.meter_attributes.active.size).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)
    end

    it 'allows creating and editing of an attribute with nested TimeOfDay values' do
      visit admin_school_single_meter_attribute_path(school, gas_meter)
      select 'Storage heaters > Storage heater configuration'
      click_on 'New attribute'

      fill_in 'Start date', with: '01/01/2023'
      fill_in 'End date', with: '01/02/2023'
      fill_in 'Power kw', with: '150'
      fill_in 'attribute_root_charge_start_time_hour', with: '3'
      fill_in 'attribute_root_charge_start_time_minutes', with: '33'
      fill_in 'attribute_root_charge_end_time_hour', with: '4'
      fill_in 'attribute_root_charge_end_time_minutes', with: '44'
      fill_in 'Reason', with: 'Testing'
      click_on 'Create'

      within '#database-meter-attributes' do
        click_on 'Edit'
      end

      expect(page).to have_field('attribute_root_charge_start_time_hour', with: '3')
      expect(page).to have_field('attribute_root_charge_start_time_minutes', with: '33')
      expect(page).to have_field('attribute_root_charge_end_time_hour', with: '4')
      expect(page).to have_field('attribute_root_charge_end_time_minutes', with: '44')

      attribute = gas_meter.meter_attributes.first
      expect(attribute.to_analytics).to eq({
        start_date: Date.new(2023, 1, 1),
        end_date: Date.new(2023, 2, 1),
        power_kw: 150.0,
        charge_start_time: TimeOfDay.new(3, 33),
        charge_end_time: TimeOfDay.new(4, 44)
      })
    end

    it 'allows creating and editing of an attribute with nested TimeOfYear values' do
      visit admin_school_single_meter_attribute_path(school, gas_meter)
      select 'Meter correction > No heating in summer set missing to zero'
      click_on 'New attribute'

      fill_in 'attribute_root_start_toy_month', with: '6'
      fill_in 'attribute_root_start_toy_day_of_month', with: '6'
      fill_in 'attribute_root_end_toy_month', with: '8'
      fill_in 'attribute_root_end_toy_day_of_month', with: '8'
      fill_in 'Reason', with: 'Testing'
      click_on 'Create'

      within '#database-meter-attributes' do
        click_on 'Edit'
      end

      expect(page).to have_field('attribute_root_start_toy_month', with: '6')
      expect(page).to have_field('attribute_root_start_toy_day_of_month', with: '6')
      expect(page).to have_field('attribute_root_end_toy_month', with: '8')
      expect(page).to have_field('attribute_root_end_toy_day_of_month', with: '8')

      attribute = gas_meter.meter_attributes.first
      expect(attribute.to_analytics).to eq({
        no_heating_in_summer_set_missing_to_zero: {
          start_toy: TimeOfYear.new(6, 6),
          end_toy: TimeOfYear.new(8, 8)
        }
      })
    end

    it 'allow the admin to manage school meter attributes' do
      visit school_path(school)
      click_on 'Meter attributes'
      click_on 'School-wide attributes'
      select 'Meter > Energy Use', from: 'type'
      click_on 'New attribute'

      check 'gas'
      select 'hotwater_only', from: 'attribute_root'

      click_on 'Create'

      expect(school.meter_attributes.size).to eq(1)
      attribute = school.meter_attributes.first
      expect { attribute.to_analytics }.not_to raise_error
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
      within 'table' do
        click_on 'Manage'
      end
      click_on 'Meter attributes'

      select 'Meter > Energy Use', from: 'type'
      click_on 'New attribute'

      check 'gas'
      select 'hotwater_only', from: 'attribute_root'

      click_on 'Create'

      expect(school_group.meter_attributes.size).to eq(1)
      attribute = school_group.meter_attributes.active.first
      expect(attribute.selected_meter_types).to eq([:gas])

      click_on 'Edit'

      check 'electricity'
      uncheck 'gas'

      click_on 'Update'

      school_group.reload
      new_attribute = school_group.meter_attributes.active.first
      expect(new_attribute.selected_meter_types).to eq([:electricity])
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      click_on 'Delete'
      expect(school_group.meter_attributes.active.size).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)
    end

    it 'allow the admin to manage global meter attributes' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Global Meter Attributes'
      select 'Meter > Energy Use', from: 'type'
      click_on 'New attribute'

      check 'gas'
      select 'hotwater_only', from: 'attribute_root'

      click_on 'Create'

      expect(GlobalMeterAttribute.count).to eq(1)
      attribute = GlobalMeterAttribute.first
      expect { attribute.to_analytics }.not_to raise_error

      click_on 'Edit'

      check 'electricity'
      uncheck 'gas'

      click_on 'Update'

      new_attribute = GlobalMeterAttribute.active.first
      expect(new_attribute.selected_meter_types).to eq([:electricity])
      attribute.reload
      expect(attribute.replaced_by).to eq(new_attribute)

      click_on 'Delete'
      expect(GlobalMeterAttribute.active.count).to eq(0)
      new_attribute.reload
      expect(new_attribute.deleted_by).to eq(admin)
    end
  end
end
