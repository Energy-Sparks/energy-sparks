# frozen_string_literal: true

require 'rails_helper'

describe OpenCloseTimes do
  describe '#convert_frontend_times' do
    let(:school_times) do
      [{ day: :monday, usage_type: :school_day, opening_time: TimeOfDay.new(7, 30), closing_time: TimeOfDay.new(16, 20), calendar_period: :term_times }]
    end
    let(:community_use_times)   { [] }
    let(:holidays)              { build(:holidays, :with_calendar_year) }
    let(:open_close_times)      { described_class.convert_frontend_times(school_times, community_use_times, holidays) }

    let(:last_year)             { Date.today.year - 1 }
    # before Autumn holiday
    let(:day)                   { Date.new(last_year, 10, 16) }

    before do
      travel_to(Date.new(2024, 12, 1))
    end

    describe 'with school times only' do
      it 'creates school times' do
        expect(open_close_times.open_times.length).to eq 1
        expect(open_close_times.usage(day)[:school_day_open]).to eq([TimeOfDay.new(7, 30)..TimeOfDay.new(16, 20)])
      end
    end

    describe 'with both' do
      let(:community_use_times) do
        [{ day: :monday, usage_type: :community_use, opening_time: TimeOfDay.new(19, 0), closing_time: TimeOfDay.new(21, 30), calendar_period: :term_times }]
      end

      it 'creates both times' do
        expect(open_close_times.open_times.length).to eq 2
        expect(open_close_times.usage(day)[:school_day_open]).to eq([TimeOfDay.new(7, 30)..TimeOfDay.new(16, 20)])
        expect(open_close_times.usage(day)[:community]).to eq([TimeOfDay.new(19, 0)..TimeOfDay.new(21, 30)])
      end
    end
  end
end
