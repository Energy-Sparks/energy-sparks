require 'rails_helper'

describe AlertTypeRatingContentVersion do

  describe 'timing validation' do

    it 'validates that the end_date is on or after the start_date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 19),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to include('must be on or after start date')
    end

    it 'allows the end date to be the same as the start date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 20),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to be_empty
    end
  end

  describe 'meets_timings?' do

    let(:start_date){ nil }
    let(:end_date){ nil }

    let(:content_version) do
      AlertTypeRatingContentVersion.new(
        find_out_more_start_date: start_date,
        find_out_more_end_date: end_date
      )
    end

    context 'with no timings defined' do
      it 'meets the timings if no start or end are defined' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end
    end

    context 'with a start date defined' do
      let(:start_date){ Date.new(2019, 5, 15) }

      it 'meets the timings if the start date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the start date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(true)
      end

      it 'does not meet the timings if the start date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(false)
      end
    end

    context 'with an end date defined' do
      let(:end_date){ Date.new(2019, 5, 15) }

      it 'meets the timings if the end date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the end date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(true)
      end

      it 'does not meet the timings if the end date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(false)
      end
    end

    context 'with both defined' do
      let(:start_date){ Date.new(2019, 5, 13) }
      let(:end_date){ Date.new(2019, 5, 15) }

      it 'meets the timings if the end date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the start date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 13))).to eq(true)
      end

      it 'meets the timings if today falls between the two dates' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(true)
      end

      it 'does not meet the timings if the end date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(false)
      end

      it 'does not meet the timings if the start date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 12))).to eq(false)
      end
    end

  end

end
