# frozen_string_literal: true

require 'rails_helper'

describe Periods::UpToTwelveMonths do
  subject(:period) do
    described_class.new(chart_config, meter_collection, amr_start_date, amr_end_date, chart_config[:timescale])
  end

  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity,
                                                    start_date: amr_start_date, end_date: amr_end_date)
  end

  let(:amr_start_date) { Date.new(2023, 1, 1) }
  let(:amr_end_date) { Date.new(2023, 12, 31) }

  let(:chart_config) do
    {
      timescale: { twelve_months: 0 }
    }
  end

  describe '#period_list' do
    subject(:period_list) do
      period.send(:period_list)
    end

    context 'with less than a month of data' do
      let(:amr_end_date)    { Date.new(2023, 1, 15) }

      it 'returns no periods' do
        expect(period_list.size).to eq(0)
      end
    end

    context 'with a month of data' do
      let(:amr_end_date) { Date.new(2023, 1, 31) }

      it 'returns single period' do
        expect(period_list.size).to eq(1)
        expect(period_list[0]).to have_attributes(start_date: amr_start_date, end_date: amr_end_date)
      end
    end

    context 'with several months of data' do
      let(:amr_end_date) { Date.new(2023, 7, 5) }

      it 'returns single period' do
        expect(period_list.size).to eq(1)
        expect(period_list[0]).to have_attributes(start_date: amr_start_date, end_date: Date.new(2023, 6, 30))
      end
    end

    context 'with exactly one year of data' do
      it 'returns single period' do
        expect(period_list.size).to eq(1)
        expect(period_list[0]).to have_attributes(start_date: amr_start_date, end_date: amr_end_date)
      end
    end

    context 'with just over a year of data' do
      let(:amr_end_date)    { Date.new(2024, 1, 15) }

      it 'returns single period' do
        expect(period_list.size).to eq(1)
        expect(period_list[0]).to have_attributes(start_date: amr_start_date, end_date: Date.new(2023, 12, 31))
      end
    end

    context 'with several calendar years of data' do
      let(:amr_start_date) { Date.new(2022, 1, 1) }

      it 'returns periods' do
        expect(period_list.size).to eq(2)
        expect(period_list[0]).to have_attributes(start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
        expect(period_list[1]).to have_attributes(start_date: Date.new(2022, 1, 1), end_date: Date.new(2022, 12, 31))
      end
    end

    context 'with several years of data' do
      let(:amr_start_date)  { Date.new(2020, 2, 15) }
      let(:amr_end_date)    { Date.new(2023, 6, 15) }

      it 'returns periods' do
        expect(period_list.size).to eq(4)
        expect(period_list[0]).to have_attributes(start_date: Date.new(2022, 6, 1), end_date: Date.new(2023, 5, 31))
        expect(period_list[1]).to have_attributes(start_date: Date.new(2021, 6, 1), end_date: Date.new(2022, 5, 31))
        expect(period_list[2]).to have_attributes(start_date: Date.new(2020, 6, 1), end_date: Date.new(2021, 5, 31))
        expect(period_list[3]).to have_attributes(start_date: Date.new(2020, 3, 1), end_date: Date.new(2020, 5, 31))
      end
    end

    context 'when there is not quite 13 months of data' do
      let(:amr_start_date)  { Date.new(2022, 12, 12) }
      let(:amr_end_date)    { Date.new(2024, 1, 15) }

      it 'returns periods' do
        expect(period_list.size).to eq(1)
        expect(period_list[0]).to have_attributes(start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
      end
    end
  end

  describe '#calculate_period_from_date' do
    subject(:school_period) do
      period.send(:calculate_period_from_date, date)
    end

    let(:date) { Date.today }

    context 'when date is outside range' do
      it { expect(school_period).to be_nil }
    end

    context 'with several years of data' do
      let(:amr_start_date)  { Date.new(2020, 2, 15) }
      let(:amr_end_date)    { Date.new(2023, 6, 15) }
      let(:date) { Date.new(2022, 1, 16) }

      it 'finds the expected period' do
        expect(school_period).to have_attributes(start_date: Date.new(2021, 6, 1), end_date: Date.new(2022, 5, 31))
      end
    end
  end

  describe '#calculate_period_from_offset' do
    subject(:school_period) do
      period.calculate_period_from_offset(1)
    end

    let(:date) { Date.today }

    context 'when date is outside range' do
      it { expect(school_period).to be_nil }
    end

    context 'with several years of data' do
      let(:amr_start_date)  { Date.new(2020, 2, 15) }
      let(:amr_end_date)    { Date.new(2023, 6, 15) }

      it 'finds the expected period' do
        expect(school_period).to have_attributes(start_date: Date.new(2021, 6, 1), end_date: Date.new(2022, 5, 31))
      end
    end
  end
end
