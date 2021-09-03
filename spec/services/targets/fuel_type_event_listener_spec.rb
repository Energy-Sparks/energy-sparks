require 'rails_helper'

describe Targets::FuelTypeEventListener, type: :system do

  let(:listener)  { Targets::FuelTypeEventListener.new }

  let!(:school)    { create(:school) }
  let!(:meter)     { create(:electricity_meter, school: school) }

  context 'storage heaters' do
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
            expect(school_target.revised_fuel_types).to match_array ["storage heater"]
          end

          it 'flags fuel types only once' do
            listener.meter_attribute_created(meter_attribute)
            listener.meter_attribute_created(create(:storage_heaters_attribute, meter: meter))
            school_target.reload
            expect(school_target.suggest_revision?).to be true
            expect(school_target.revised_fuel_types).to match_array ["storage heater"]
          end

        end
      end
    end
  end
end
