# frozen_string_literal: true

require 'rails_helper'

describe Alerts::Electricity::UsageDuringCurrentHolidayWithCommunityUse do
  subject(:alert) { described_class.new(meter_collection) }

  context 'when a school has electricity' do
    include_context 'with an aggregated meter with tariffs and school times'
    it_behaves_like 'a holiday usage alert' do
      context 'with community use' do
        let(:community_use_times) do
          [{ day: :weekdays, usage_type: :community_use, calendar_period: :all_year,
             opening_time: TimeOfDay.new(15, 0), closing_time: TimeOfDay.new(20, 0) }]
        end

        before { alert.analyse(asof_date) }

        it 'calculates expected usage', :aggregate_failures do
          expect(alert.community_usage_to_date_kwh).to be_within(0.001).of(500.0)
          expect(alert.community_usage_to_date_gbp).to be_within(0.001).of(50.0)
          expect(alert.community_usage_to_date_co2).to be_within(0.001).of(100.0)
        end
      end
    end
  end

  # context 'when a school has gas only' do
  #   include_context 'with an aggregated meter with tariffs and school times' do
  #     let(:fuel_type) { :gas }
  #   end
  #   include_context 'with today'

  #   let(:asof_date) { Date.new(2023, 12, 23) }

  #   it 'is never relevant' do
  #     expect(alert.relevance).to eq(:never_relevant)
  #   end
  # end
end
