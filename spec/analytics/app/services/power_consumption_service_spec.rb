# frozen_string_literal: true

require 'rails_helper'

describe PowerConsumptionService do
  let(:school)                  { build(:analytics_school) }
  let(:meter_collection)        { build(:meter_collection) }
  let(:meter)                   { build(:meter, type: :electricity) }

  let(:service)                 { described_class.create_service(meter_collection, meter) }

  describe '#create_service' do
    it 'creates without error' do
      expect(service).not_to be_nil
    end
  end

  describe '#perform' do
    it 'returns a reading' do
      expect(service.perform).to be_a(Float)
    end
  end
end
