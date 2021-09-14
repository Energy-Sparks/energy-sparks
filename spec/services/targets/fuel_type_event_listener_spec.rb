require 'rails_helper'

describe Targets::FuelTypeEventListener, type: :system do

  let(:listener)  { Targets::FuelTypeEventListener.new }

  let!(:school)    { create(:school) }
  let!(:meter)     { create(:electricity_meter, school: school) }

  describe '#meter_attribute_created' do
    context 'with a school target' do
      let!(:school_target)   { create(:school_target, school: school) }

      context 'for non storage heater attributes' do
        let(:meter_attribute) { create(:meter_attribute) }

        before(:each) do
          listener.meter_attribute_created(meter_attribute)
        end

        it 'does nothing' do
          expect(school_target.suggest_revision?).to be false
          expect(school_target.revised_fuel_types).to be_empty
        end
      end

      context 'for storage heater attributes' do
        let(:meter_attribute) { create(:storage_heaters_attribute, meter: meter) }

        it 'updated target when its the first' do
          listener.meter_attribute_created(meter_attribute)
          school_target.reload
          expect(school_target.suggest_revision?).to be true
          expect(school_target.revised_fuel_types).to match_array ["storage_heater"]
        end

        it 'flags fuel types only once' do
          listener.meter_attribute_created(meter_attribute)
          listener.meter_attribute_created(create(:storage_heaters_attribute, meter: meter))
          school_target.reload
          expect(school_target.suggest_revision?).to be true
          expect(school_target.revised_fuel_types).to match_array ["storage_heater"]
        end

        it 'removes flag if the list is empty' do
          school_target.update!(revised_fuel_types: ["storage_heater"])
          meter_attribute.update!(deleted_by: create(:admin))
          listener.meter_attribute_deleted(meter_attribute)
          school_target.reload
          expect(school_target.suggest_revision?).to be false
          expect(school_target.revised_fuel_types).to be_empty
        end

      end
    end
  end

  describe '#meter_activated' do
    let!(:gas_meter) { create(:gas_meter, school: school) }

    context 'with a school target' do
        let!(:school_target)   { create(:school_target, school: school) }

        it 'updates target when its the first gas meter' do
          listener.meter_activated(gas_meter)
          school_target.reload
          expect(school_target.suggest_revision?).to be true
          expect(school_target.revised_fuel_types).to match_array ["gas"]
        end

        it 'updates target when its the first electricity meter' do
          listener.meter_activated(meter)
          school_target.reload
          expect(school_target.suggest_revision?).to be true
          expect(school_target.revised_fuel_types).to match_array ["electricity"]
        end

        it 'flags fuel types only once' do
          listener.meter_activated(gas_meter)
          other_meter = create(:gas_meter, school: school)
          listener.meter_activated(other_meter)
          school_target.reload
          expect(school_target.revised_fuel_types).to match_array ["gas"]
        end

        it 'removes flag is last meter of type' do
          gas_meter.update!(active: false)
          listener.meter_deactivated(gas_meter)
          school_target.reload
          expect(school_target.suggest_revision?).to be false
        end
    end
  end
end
