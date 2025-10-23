# frozen_string_literal: true

require 'rails_helper'

describe AlertElectricityLongTermTrend do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  context 'with two years of changing data' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:amr_start_date)  { Date.new(2021, 12, 31) }
      let(:amr_end_date)    { Date.new(2024, 12, 31) }

      # use existing function to change data for most recent year
      before do
        amr_data.scale_kwh(scale, date1: amr_end_date - 363, date2: amr_end_date)
      end
    end
    include_context 'with today'

    let(:asof_date) { Date.new(2024, 12, 31) }

    before do
      alert.analyse(asof_date)
    end

    let(:unchanged_annual_use) do
      364 * daily_usage # values from shared context over a year
    end

    context 'with increased usage' do
      let(:scale) { 2.0 }

      it 'produces expected change variables' do
        expect(alert.last_year_kwh).to eq(unchanged_annual_use) # values from context
        expect(alert.this_year_kwh).to eq(unchanged_annual_use * scale)
        expect(alert.year_change_kwh).to eq(unchanged_annual_use)
        expect(alert.abs_difference_kwh).to eq(unchanged_annual_use)
        expect(alert.percent_change_kwh).to eq(1.0) # 100 percent increase
      end
    end

    context 'with decreased usage' do
      let(:scale) { 0.5 }

      it 'produces expected change variables' do
        expect(alert.last_year_kwh).to eq(unchanged_annual_use) # values from context
        expect(alert.this_year_kwh).to eq(unchanged_annual_use * scale)
        expect(alert.year_change_kwh).to eq(unchanged_annual_use * scale * -1.0)
        expect(alert.abs_difference_kwh).to eq(unchanged_annual_use * scale)
        expect(alert.percent_change_kwh).to eq(-0.5) # 50 percent decrease
      end
    end
  end
end
