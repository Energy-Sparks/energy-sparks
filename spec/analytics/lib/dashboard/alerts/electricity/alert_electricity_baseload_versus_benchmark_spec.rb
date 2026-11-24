# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'

RSpec.describe AlertElectricityBaseloadVersusBenchmark do
  subject(:alert) { described_class.new(meter_collection, :baseloadbenchmark, meter) }

  include_context 'with short-term alert readings'

  let(:meter) { aggregate_meter }

  it_behaves_like 'an alert requiring a minimum number of non-estimated readings', minimum_days: 1

  describe '#enough_data' do
    context 'with an individual meter' do
      let(:meter) { build(:meter, meter_collection:, type: :electricity, amr_data:) }

      it 'still rejects the data' do
        expect(alert.enough_data).to eq(:not_enough)
      end
    end
  end

  it_behaves_like 'an alert without a freshness limit'

  it_behaves_like 'a never relevant alert', :gas
end
