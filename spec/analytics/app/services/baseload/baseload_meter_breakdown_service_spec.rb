# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseloadCalculationService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:service)        { Baseload::BaseloadMeterBreakdownService.new(@acme_academy) }

  let(:meter1)        { 1_591_058_886_735 }
  let(:meter2)        { 1_580_001_320_420 }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#calculate_breakdown' do
    it 'runs the calculation' do
      meter_breakdown = service.calculate_breakdown
      expect(meter_breakdown.meters).to match_array([meter1, meter2])
      expect(meter_breakdown.baseload_kw(meter1)).not_to be_nil
      expect(meter_breakdown.percentage_baseload(meter1)).not_to be_nil
      expect(meter_breakdown.baseload_cost_£(meter1)).not_to be_nil

      kw1 = meter_breakdown.baseload_kw(meter1)
      kw2 = meter_breakdown.baseload_kw(meter2)
      expect(meter_breakdown.total_baseload_kw).to eq(kw1 + kw2)

      perc1 = meter_breakdown.percentage_baseload(meter1)
      perc2 = meter_breakdown.percentage_baseload(meter2)
      expect(perc1 + perc2).to eq(1.0)

      expect(meter_breakdown.meters_by_baseload).to match_array([meter2, meter1])
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
        expect(service.data_available_from).to be nil
      end
    end

    context 'when theres is limited data' do
      # acme academy has data starting in 2019-01-13
      let(:asof_date) { Date.new(2019, 1, 21) }

      before do
        allow_any_instance_of(AMRData).to receive(:end_date).and_return(asof_date)
      end

      it 'returns false' do
        expect(service.enough_data?).to be false
        expect(service.data_available_from).not_to be nil
      end
    end
  end
end
