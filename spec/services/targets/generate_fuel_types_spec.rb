# frozen_string_literal: true

require 'rails_helper'

describe Targets::GenerateFuelTypes do
  subject!(:service) { described_class.new(school, aggregated_school) }

  let!(:school) { create(:school) }
  let!(:aggregated_school) { build(:meter_collection, :with_aggregate_meter) }
  let!(:school_target) { create(:school_target, school: school) }
  let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types) { ['electricity'] }

  before { create(:configuration, school:, fuel_configuration:, school_target_fuel_types:) }

  describe '#fuel_types_with_enough_data' do
    it 'is empty with no data' do
      expect(service.fuel_types_with_enough_data).to eq([])
    end

    context 'with an exception' do
      before do
        mock_object = instance_double(Targets::TargetsService)
        allow(mock_object).to receive(:enough_data_to_set_target?).and_raise(StandardError, 'error')
        allow(Targets::TargetsService).to receive(:new).and_return(mock_object)
      end

      it 'handles the exception' do
        expect(service.fuel_types_with_enough_data).to eq([])
      end
    end
  end
end
