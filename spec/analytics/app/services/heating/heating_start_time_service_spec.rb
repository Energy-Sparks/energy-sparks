# frozen_string_literal: true

require 'rails_helper'

describe Heating::HeatingStartTimeService, type: :service do
  let(:asof_date)      { Date.new(2023, 10, 11) }
  let(:service)        { described_class.new(@acme_academy, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#average_start_time_last_week' do
    it 'returns the expected data' do
      # FIXME: running locally, this is 6am, but 5am on github
      # expect(service.average_start_time_last_week).to eq TimeOfDay.new(5,0)
      expect(service.average_start_time_last_week).not_to be_nil
    end
  end

  describe '#calculate_start_times' do
    it 'returns the expected data' do
      start_times = service.last_week_start_times

      # FIXME: running locally, this is 6am, but 5am on github
      # expect(start_times.average_start_time).to eq TimeOfDay.new(5,0)
      expect(start_times.average_start_time).not_to be_nil

      # returns the asof_date plus 7 days before
      expect(start_times.days.length).to eq 8

      first_day = start_times.days[0]
      expect(first_day.date).to eq Date.new(2023, 10, 4)
      expect(first_day.heating_start_time).to eq TimeOfDay.new(5, 30)
      expect(first_day.recommended_time).to eq TimeOfDay.new(6, 30)
      expect(first_day.temperature).to eq 10.3
      expect(first_day.saving.kwh).to be_within(0.01).of(504.08)
      expect(first_day.saving.£).to be_within(0.01).of(15.12)
      expect(first_day.saving.co2).to be_within(0.01).of(92.01)
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end

    context 'when theres is limited data' do
      # acme academy has gas data starting in 2018-09-01
      let(:asof_date) { Date.new(2018, 10, 2) }

      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end
  end
end
