require 'rails_helper'

RSpec.describe 'meter attribute management', :meters, type: :system do
  let!(:school_group)       { create(:school_group, name: 'BANES') }
  let!(:school_name)        { 'Oldfield Park Infants' }
  let!(:school)             { create_active_school(name: school_name, school_group: school_group) }
  let!(:admin)              { create(:admin) }
  let!(:gas_meter)          { create(:gas_meter, name: 'Gas meter', school: school) }

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
        within '#manage-school-menu' do
          click_on 'Meter attributes'
        end
        expect(page).to have_text('Meter attributes for Oldfield Park Infants')
        expect(page).to have_text('There was an error')
      end

      it 'deletes broken meter attribute' do
        create(:meter_attribute, meter: gas_meter)
        visit school_path(school)
        within '#manage-school-menu' do
          click_on 'Meter attributes'
        end
        click_on 'Delete'
        expect(gas_meter.reload.meter_attributes.active.count).to eq(0)
        expect(gas_meter.reload.meter_attributes.deleted.count).to eq(1)
        expect(page).to have_text('There was an error')
      end

      it 'deletes broken school attribute' do
        create(:school_meter_attribute, school: school)
        visit school_path(school)
        within '#manage-school-menu' do
          click_on 'Meter attributes'
        end
        click_on 'School-wide attributes'
        click_on 'Delete'
        expect(school.reload.meter_attributes.active.count).to eq(0)
        expect(school.reload.meter_attributes.deleted.count).to eq(1)
        expect(page).to have_text('There was an error')
      end

      it 'deletes broken global meter attribute' do
        create(:global_meter_attribute)
        visit admin_path(school)
        click_on 'Global Meter Attributes'
        click_on 'Delete'
        expect(GlobalMeterAttribute.active.count).to eq(0)
        expect(GlobalMeterAttribute.deleted.count).to eq(1)
        expect(page).to have_text('There was an error')
      end
    end

    it 'is able to display a form for all meter attributes' do
      visit admin_school_single_meter_attribute_path(school, gas_meter)
      options = find_by_id('type').all('option').collect(&:text)

      options.each do |option|
        select option, from: 'type'
        click_on 'New attribute'
        expect(page).to have_button('Create')
        visit admin_school_single_meter_attribute_path(school, gas_meter)
      end
    end

    describe 'managing meter attributes' do
      before do
        visit school_path(school)
        within '#manage-school-menu' do
          click_on 'Meter attributes'
        end
      end

      context 'when creating an attribute' do
        let(:attribute) { gas_meter.meter_attributes.first }

        before do
          select 'Heating model', from: 'type'
          click_on 'New attribute'
          fill_in 'Max summer daily heating kwh', with: 800
          click_on 'Create'
        end

        it 'allows creation of an attribute' do
          expect(gas_meter.meter_attributes.size).to eq(1)
          expect { attribute.to_analytics }.not_to raise_error
          expect(attribute.to_analytics.to_s).to include('800')
        end
      end

      context 'when editing an attribute' do
        let!(:meter_attribute) do
          create(:meter_attribute, attribute_type: 'heating_model',
                                   input_data: { max_summer_daily_heating_kwh: 300 }, meter: gas_meter)
        end

        let(:new_attribute) { gas_meter.meter_attributes.active.first }

        before do
          refresh
          within '#database-meter-attributes' do
            click_on 'Edit'
          end
          fill_in 'Max summer daily heating kwh', with: 200
          click_on 'Update'
          gas_meter.reload
        end

        it 'allows editing of an attribute' do
          meter_attribute.reload
          expect(new_attribute.to_analytics.to_s).to include('200')
          expect(meter_attribute.replaced_by).to eq(new_attribute)
        end
      end

      context 'when deleting an attribute' do
        let!(:meter_attribute) do
          create(:meter_attribute, attribute_type: 'heating_model',
                                   input_data: { max_summer_daily_heating_kwh: 300 }, meter: gas_meter)
        end

        before do
          refresh
          within '#database-meter-attributes' do
            click_on 'Delete'
          end
        end

        it 'allows deletion of an attribute' do
          expect(gas_meter.meter_attributes.active.size).to eq(0)
          meter_attribute.reload
          expect(meter_attribute.deleted_by).to eq(admin)
        end
      end

      context 'when restoring an attribute' do
        let!(:meter_attribute) do
          create(:meter_attribute, attribute_type: 'heating_model',
                                   input_data: { max_summer_daily_heating_kwh: 300 }, meter: gas_meter)
        end

        before do
          refresh
          within '#database-meter-attributes' do
            click_on 'Delete'
          end
          within '#deleted-meter-attributes-content' do
            click_on 'Restore'
          end
        end

        it 'allows restoration of an attribute' do
          expect(gas_meter.meter_attributes.active.size).to eq(1)
          meter_attribute.reload
          expect(meter_attribute.deleted_by).to be_nil
        end
      end
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

    describe 'managing school meter attributes' do
      before do
        visit school_path(school)
        within '#manage-school-menu' do
          click_on 'Meter attributes'
        end
        click_on 'School-wide attributes'
      end

      context 'when creating an attribute' do
        let(:attribute) { school.meter_attributes.first }

        before do
          select 'Meter > Energy Use', from: 'type'
          click_on 'New attribute'
          check 'gas'
          select 'hotwater_only', from: 'attribute_root'
          click_on 'Create'
        end

        it 'allows the creation of an attribute' do
          expect(school.meter_attributes.size).to eq(1)
          expect { attribute.to_analytics }.not_to raise_error
          expect(attribute.to_analytics.to_s).to include('hotwater_only')
        end
      end

      context 'when editing an attribute' do
        let!(:school_meter_attribute) do
          create(:school_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'heating_only', school:)
        end

        let(:new_attribute) { school.meter_attributes.active.first }

        before do
          refresh
          within '#database-group-meter-attributes-content' do
            click_on 'Edit'
          end
          select 'kitchen_only', from: 'attribute_root'
          click_on 'Update'
          school.reload
        end

        it 'allows editing an attribute' do
          expect(new_attribute.to_analytics.to_s).to include('kitchen_only')
          school_meter_attribute.reload
          expect(school_meter_attribute.replaced_by).to eq(new_attribute)
        end
      end

      context 'when deleting an attribute' do
        let!(:school_meter_attribute) do
          create(:school_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'heating_only', school:)
        end

        before do
          refresh
          within '#database-group-meter-attributes-content' do
            click_on 'Delete'
          end
        end

        it 'allows the deletion of an attribute' do
          expect(school.meter_attributes.active.size).to eq(0)
          school_meter_attribute.reload
          expect(school_meter_attribute.deleted_by).to eq(admin)
        end
      end

      context 'when restoring an attribute' do
        let!(:school_meter_attribute) do
          create(:school_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'heating_only', school:)
        end

        before do
          refresh
          within '#database-group-meter-attributes-content' do
            click_on 'Delete'
          end
          within '#deleted-group-meter-attributes-content' do
            click_on 'Restore'
          end
        end

        it 'allows restoration of an attribute' do
          expect(school.meter_attributes.active.size).to eq(1)
          school_meter_attribute.reload
          expect(school_meter_attribute.deleted_by).to be_nil
        end
      end
    end

    describe 'managing school group meter attributes' do
      let(:attribute) { school_group.meter_attributes.active.first }

      before do
        visit root_path
        click_on 'Manage'
        click_on 'Admin Home'
        click_on 'School Groups'
        within 'table' do
          click_on 'Manage'
        end
        within '#school-group-button-panel' do
          click_on 'Meter attributes'
        end
      end

      context 'when creating an attribute' do
        before do
          select 'Meter > Energy Use', from: 'type'
          click_on 'New attribute'
          check 'gas'
          select 'hotwater_only', from: 'attribute_root'
          click_on 'Create'
        end

        it 'allows the creation of an attribute' do
          expect(school_group.meter_attributes.size).to eq(1)
          expect(attribute.selected_meter_types).to eq([:gas])
        end
      end

      context 'when editing an attribute' do
        let!(:school_group_meter_attribute) do
          create(:school_group_meter_attribute, attribute_type: 'function_switch',
                                                input_data: 'hotwater_only', school_group:)
        end
        let(:new_attribute) { school_group.meter_attributes.active.first }

        before do
          refresh
          click_on 'Edit'
          check 'electricity'
          uncheck 'gas'
          click_on 'Update'
          school_group.reload
        end

        it 'allows editing of an attibute' do
          expect(new_attribute.selected_meter_types).to eq([:electricity])
          school_group_meter_attribute.reload
          expect(school_group_meter_attribute.replaced_by).to eq(new_attribute)
        end
      end

      context 'when deleting an attribute' do
        let!(:school_group_meter_attribute) do
          create(:school_group_meter_attribute, attribute_type: 'function_switch',
                                                input_data: 'hotwater_only', school_group:)
        end

        before do
          refresh
          click_on 'Delete'
        end

        it 'allows deletion of an attribute' do
          expect(school_group.meter_attributes.active.size).to eq(0)
          school_group_meter_attribute.reload
          expect(school_group_meter_attribute.deleted_by).to eq(admin)
        end
      end

      context 'when restoring an attribute' do
        let!(:school_group_meter_attribute) do
          create(:school_group_meter_attribute, attribute_type: 'function_switch',
                                                input_data: 'hotwater_only', school_group:)
        end

        before do
          refresh
          click_on 'Delete'
          click_on 'Restore'
        end

        it 'allows restoration of an attribute' do
          expect(school_group.meter_attributes.active.size).to eq(1)
          school_group_meter_attribute.reload
          expect(school_group_meter_attribute.deleted_by).to be_nil
        end
      end
    end

    describe 'managing global meter attributes' do
      before do
        visit root_path
        click_on 'Manage'
        click_on 'Admin Home'
        click_on 'Global Meter Attributes'
      end

      context 'when creating an attribute' do
        let(:attribute) { GlobalMeterAttribute.first }

        before do
          select 'Meter > Energy Use', from: 'type'
          click_on 'New attribute'
          check 'gas'
          select 'hotwater_only', from: 'attribute_root'
          click_on 'Create'
        end

        it 'allows creation of an attribute' do
          expect(GlobalMeterAttribute.count).to eq(1)
          expect { attribute.to_analytics }.not_to raise_error
        end
      end

      context 'when editing an attribute' do
        let!(:global_meter_attribute) do
          create(:global_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'hotwater_only')
        end
        let(:new_attribute) { GlobalMeterAttribute.active.first }

        before do
          refresh
          click_on 'Edit'
          check 'electricity'
          uncheck 'gas'
          click_on 'Update'
        end

        it 'allows editing of an attribute' do
          expect(new_attribute.selected_meter_types).to eq([:electricity])
          global_meter_attribute.reload
          expect(global_meter_attribute.replaced_by).to eq(new_attribute)
        end
      end

      context 'when deleting an attribute' do
        let!(:global_meter_attribute) do
          create(:global_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'hotwater_only')
        end

        before do
          refresh
          click_on 'Delete'
        end

        it 'allows deletion of an attribute' do
          expect(GlobalMeterAttribute.active.count).to eq(0)
          global_meter_attribute.reload
          expect(global_meter_attribute.deleted_by).to eq(admin)
        end
      end

      context 'when restoring an attribute' do
        let!(:global_meter_attribute) do
          create(:global_meter_attribute, attribute_type: 'function_switch',
                                          input_data: 'hotwater_only')
        end

        before do
          refresh
          click_on 'Delete'
          click_on 'Restore'
        end

        it 'allows restoration of an attribute' do
          expect(GlobalMeterAttribute.active.count).to eq(1)
          global_meter_attribute.reload
          expect(global_meter_attribute.deleted_by).to be_nil
        end
      end
    end
  end
end
