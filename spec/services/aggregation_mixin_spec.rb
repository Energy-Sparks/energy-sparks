# frozen_string_literal: true

require 'rails_helper'

describe AggregationMixin do
  describe '#aggregate_amr_data_between_dates' do
    subject(:combined_amr_data) do
      aggregator.send(:aggregate_amr_data_between_dates, meters, :electricity, date, end_date)
    end

    let(:aggregator) { Object.new.extend(described_class) }
    let(:date) { Date.new(2026) }
    let(:end_date) { date + 1.day }
    let(:meters) do
      reading_types.map do |reading_type|
        amr_data = build(:amr_data, :with_date_range, start_date: date, end_date:, reading_type:,
                                                      kwh_data_x48: Array.new(48, 1.0))
        build(:meter, amr_data: amr_data)
      end
    end

    { %w[ORIG ORIG] => 'ORIG',
      %w[EST ORIG] => 'EST',
      %w[ORIG EST] => 'EST',
      %w[EST EST] => 'EST',
      %w[AGGR ORIG] => 'ORIG' }.each do |types, expected_status|
      context "with #{types.join(' and ')} readings" do
        let(:reading_types) { types }

        it "assigns #{expected_status} to the aggregated readings" do
          expect(combined_amr_data[date].type).to eq(expected_status)
          expect(combined_amr_data[date].kwh_data_x48).to eq(Array.new(48, 2.0))
        end
      end
    end

    context 'when an estimated meter has no reading on the following day' do
      let(:reading_types) { %w[ORIG EST] }

      before do
        meters.last.amr_data.delete(date + 1)
      end

      it 'determines the status separately for each date using only contributing readings' do
        expect(combined_amr_data[date].type).to eq('EST')
        expect(combined_amr_data[date + 1].type).to eq('ORIG')
        expect(combined_amr_data[date + 1].kwh_data_x48).to eq(Array.new(48, 1.0))
      end
    end
  end
end
