# frozen_string_literal: true

require 'rails_helper'

describe AlertElectricityUsageDuringCurrentHoliday do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  context 'when a school has electricity' do
    include_context 'with an aggregated meter with tariffs and school times'
    it_behaves_like 'a holiday usage alert' do
      describe '#enough_data' do
        context 'with community use' do
          let(:community_use_times) do
            [{ day: :weekdays, usage_type: :community_use, calendar_period:,
              opening_time: TimeOfDay.new(15, 0), closing_time: TimeOfDay.new(20, 0) }]
          end

          context 'with all year community use' do
            let(:calendar_period) { :all_year }

            it { expect(alert.enough_data).to eq(:not_enough) }
          end

          context 'with term community use' do
            let(:calendar_period) { :term_times }

            it { expect(alert.enough_data).to eq(:enough) }
          end
        end
      end
    end
  end

  context 'when a school has gas only' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { :gas }
    end
    include_context 'with today'

    let(:asof_date) { Date.new(2023, 12, 23) }

    it 'is never relevant' do
      expect(alert.relevance).to eq(:never_relevant)
    end
  end
end
