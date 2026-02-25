# frozen_string_literal: true

require 'rails_helper'

describe Series::Baseload do # rubocop:disable RSpec/SpecFilePathFormat
  describe '#day_breakdown' do
    it 'calculates baseload' do
      meter_collection = build(:meter_collection, :with_aggregated_aggregate_meter)
      amr_data = meter_collection.electricity_meters.first.amr_data
      series = described_class.new(meter_collection, { meter_definition: :allelectricity })
      expect(series.day_breakdown(amr_data.start_date, amr_data.end_date)).to eq({ 'BASELOAD' => 2.0 })
    end
  end
end
