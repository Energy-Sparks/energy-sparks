require 'rails_helper'

describe Meters::MeterAttributeManager, type: :service do

  let(:admin)       { create(:admin) }
  let(:school)      { create(:school) }
  let(:meter)       { create(:electricity_meter, school: school ) }

  let!(:service)    { Meters::MeterAttributeManager.new(school) }

  let(:attribute_type) { :function_switch }
  let(:reason)         { 'testing' }
  let(:input_data)     { 'heating_only' }

  context '#create!' do
    context 'with valid attributes' do
      it 'creates the attribute' do
        expect { service.create!(meter.id, attribute_type, input_data, reason, admin) }.to change(MeterAttribute, :count).from(0).to(1)
      end

      it 'broadcasts an event' do
        expect { service.create!(meter.id, attribute_type, input_data, reason, admin) }.to broadcast(:meter_attribute_created)
      end

      it 'registers the target event listener' do
        expect_any_instance_of(Targets::FuelTypeEventListener).to receive(:meter_attribute_created)
        service.create!(meter.id, attribute_type, input_data, reason, admin)
      end
    end

    context 'with invalid attributes' do
      it 'doesnt create the attribute' do
        expect { service.create!(meter.id, attribute_type, "invalid", reason, admin) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context '#update!' do
    let!(:meter_attribute) { create(:meter_attribute) }

    context 'with valid attributes' do
      it 'creates a new linked attribute' do
        expect { service.update!(meter_attribute.id, input_data, reason, admin) }.to change(MeterAttribute, :count).from(1).to(2)
        meter_attribute.reload
        expect(meter_attribute.replaced_by).to_not be nil
      end

      it 'broadcasts an event' do
        expect { service.update!(meter_attribute.id, input_data, reason, admin) }.to broadcast(:meter_attribute_updated)
      end

    end
    context 'with invalid attributes' do
      it 'doesnt create a new attribute' do
        expect { service.update!(meter_attribute.id, "invalid", reason, admin) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context '#delete!' do
    let(:meter_attribute) { create(:meter_attribute) }

    it 'delete the attribute' do
      service.delete!(meter_attribute.id, admin)
      meter_attribute.reload
      expect(meter_attribute.deleted_by).to eql admin
    end

    it 'broadcasts an event' do
      expect { service.delete!(meter_attribute.id, admin) }.to broadcast(:meter_attribute_deleted, meter_attribute)
    end
  end

end
