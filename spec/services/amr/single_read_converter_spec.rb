require 'rails_helper'

module Amr
  describe SingleReadConverter do
    subject(:converter) { described_class.new(config, readings) }

    let(:config) { create(:amr_data_feed_config, row_per_reading: true) }

    let(:valid_reading_times) do
      48.times.map do |hh|
        TimeOfDay.time_of_day_from_halfhour_index(hh).to_s
      end
    end

    def create_hh_readings
      48.times.collect { |i| (i + 1).to_f }
    end

    def create_reading(config, mpan_mprn, reading_date, readings, meter_id: nil)
      {
        amr_data_feed_config_id: config.id,
        meter_id: meter_id,
        mpan_mprn: mpan_mprn,
        reading_date: reading_date,
        readings: readings
      }
    end

    def create_reading_for_period(config, mpan_mprn, reading_date, period, readings, meter_id: nil)
      create_reading(config, mpan_mprn, reading_date, readings, meter_id: meter_id).merge({ period: period })
    end

    def create_reading_for_time(config, mpan_mprn, reading_date, reading_time, readings, meter_id: nil)
      create_reading(config, mpan_mprn, reading_date, readings, meter_id: meter_id).merge({ reading_time: reading_time })
    end

    context 'with a reading timestamp column' do
      # This is the EnergySparks default.
      # Matches the EDF format
      # So 26 Aug 2019 00:00 means usage FROM midnight to 00:30am on the 26th August
      # So 26 Aug 2019 23:30 means usage FROM 23:30 to midnight on the 26th August
      context 'with readings labelled at start of the half hour, so 00:00 is start of the day (%H:%M:%s) and correct config' do
        let(:config) { create(:amr_data_feed_config, :with_row_per_reading, half_hourly_labelling: :start, date_format: '%d %b %Y %H:%M') }

        let(:mpan_mprn) { '1710035168313' }
        let(:reading_date) { '26 Aug 2019' }
        let(:readings) do
          48.times.collect do |hh|
            hh_time = TimeOfDay.time_of_day_from_halfhour_index(hh).to_s
            create_reading(config, mpan_mprn, "#{reading_date} #{hh_time}:00", [(hh + 1).to_s])
          end
        end
        let(:expected_output) do
          [create_reading(config, mpan_mprn, Date.parse(reading_date), 48.times.collect { |i| (i + 1) })]
        end

        it 'converts correctly' do
          expect(converter.perform).to eq expected_output
        end
      end

      # Opposite to our default assumption
      # So 26 Aug 2019 23:30 means usage UP TO 23:30 on 26th August
      # So 27 Aug 2019 00:00 means usage FROM 23:30 on 26th August to 00:00
      context 'with readings labelled at end of the half hour so 00:00 is end of the day' do
        let(:mpan_mprn) { '1710035168313' }

        context 'with date times formatted as %d %b %Y %H:%M' do
          let(:reading_date) { Date.parse('26 Aug 2019') }
          let(:meter_id) { nil }
          # This is testing with timestamps from 26 Aug 2019 00:30 to 26 Aug 23:30 plus 27 Aug 00:00
          let(:readings) do
            48.times.collect do |hh|
              date = hh < 47 ? reading_date.strftime('%d %b %Y') : (reading_date + 1).strftime('%d %b %Y')
              date_time = hh < 47 ? "#{date} #{TimeOfDay.time_of_day_from_halfhour_index(hh + 1)}" : "#{date} 00:00"
              create_reading(config, mpan_mprn, date_time, [(hh + 1).to_s], meter_id: meter_id)
            end
          end

          let(:expected_output) do
            [create_reading(config, mpan_mprn, reading_date, create_hh_readings)]
          end

          it 'converts correctly' do
            expect(converter.perform).to eq expected_output
          end

          context 'when readings are matched to meter' do
            let(:meter_id) { 1 }

            let(:expected_output) do
              [create_reading(config, mpan_mprn, reading_date, create_hh_readings, meter_id: meter_id)]
            end

            it 'preserves the ids' do
              expect(converter.perform).to eq expected_output
            end
          end
        end

        # TODO: this fails locally, but not on github. We end up with 26 Aug 2019 having 49 values with 2 nils, plus
        # 27th August having 48 nil values and a single value (48) a position 1 in the array
        context 'with date times formatted as ISO 8601 (as produced by xlsx to csv conversion)' do
          let(:reading_date) { Time.zone.parse('26 Aug 2019') }

          # this is testing with timestamps from 2019-08-26T00:30:00Z to 2019-08-27T00:00:00Z.
          let(:readings) do
            48.times.collect do |i|
              { :amr_data_feed_config_id => config.id, :mpan_mprn => mpan_mprn, :reading_date => (reading_date + ((i + 1) * 30).minutes).iso8601, :readings => [(i + 1).to_s] }
            end
          end

          let(:expected_output) do
            [create_reading(config, mpan_mprn, reading_date.to_date, create_hh_readings)]
          end

          it 'converts correctly' do
            expect(converter.perform).to eq expected_output
          end
        end
      end
    end

    context 'with separate date and time columns' do
      let(:config) { create(:amr_data_feed_config, :with_reading_time_field) }

      let(:mpan_mprn) { '1710035168313' }
      let(:reading_date) { '26 Aug 2019' }

      let(:expected_output) do
        [create_reading(config, mpan_mprn, Date.parse(reading_date), 48.times.collect { |i| (i + 1) })]
      end

      context 'with times formatted as %H:%M' do
        let(:readings) do
          valid_reading_times.each.with_index(1).map do |hh_time, index|
            create_reading_for_time(config, mpan_mprn, reading_date, hh_time, [index.to_s])
          end
        end

        it 'converts correctly' do
          expect(converter.perform).to eq expected_output
        end
      end

      context 'with times formatted as %H%M' do
        let(:readings) do
          valid_reading_times.each.with_index(1).map do |hh_time, index|
            create_reading_for_time(config, mpan_mprn, reading_date, hh_time.sub(':', ''), [index.to_s])
          end
        end

        it 'converts correctly' do
          expect(converter.perform).to eq expected_output
        end

        it 'handles files with multiple mpans' do
          # create test data that consists of 2 days readings for 2 different meters
          two_meters_worth_of_readings = readings + readings.map {|r| { amr_data_feed_config_id: 6, mpan_mprn: '123456789012', reading_date: r[:reading_date], reading_time: r[:reading_time], readings: r[:readings] } }

          results = described_class.new(config, two_meters_worth_of_readings).perform

          # create expected output: 2 x 2 days readings for 2 meters
          expected_results = expected_output + expected_output.map {|r| { amr_data_feed_config_id: 6, meter_id: nil, mpan_mprn: '123456789012', reading_date: r[:reading_date], readings: r[:readings] } }

          expect(results).to eq expected_results
        end
      end

      context 'with times formatted without padding (0, 30, 100, 130..2330)' do
        let(:readings) do
          valid_reading_times.each.with_index(1).map do |hh_time, index|
            time = index == 1 ? '0' : hh_time.sub(':', '').gsub(/^0+/, '')
            create_reading_for_time(config, mpan_mprn, reading_date, time, [index.to_s])
          end
        end

        it 'converts correctly' do
          expect(converter.perform).to eq expected_output
        end
      end
    end

    context 'with numbered half-hourly periods (positional_index: true)' do
      let(:config) { create(:amr_data_feed_config, :with_positional_index) }

      let(:mpan_mprn) { '1710035168313' }
      let(:reading_date) { '26 Aug 2019' }

      let(:readings) do
        48.times.collect { |hh| create_reading_for_period(config, mpan_mprn, reading_date, (hh + 1).to_s, [(hh + 1).to_s]) }
      end

      let(:expected_output) do
        [create_reading(config, mpan_mprn, Date.parse(reading_date), create_hh_readings)]
      end

      it 'converts correctly' do
        expect(converter.perform).to eq expected_output
      end

      it 'handles files with multiple mpans' do
        # create test data that consists of 2 days readings for 2 different meters
        two_meters_worth_of_readings = readings + readings.map {|r| { amr_data_feed_config_id: 6, mpan_mprn: '123456789012', reading_date: r[:reading_date], period: r[:period], readings: r[:readings] } }

        results = described_class.new(config, two_meters_worth_of_readings).perform

        # create expected output: 2 x 2 days readings for 2 meters
        expected_results = expected_output + expected_output.map {|r| { amr_data_feed_config_id: 6, meter_id: nil, mpan_mprn: '123456789012', reading_date: r[:reading_date], readings: r[:readings] } }

        expect(results).to eq expected_results
      end
    end

    context 'when data is invalid' do
      context 'with missing mpan_mprn' do
        let(:readings) { [create_reading(config, nil, '27 Aug 2019', create_hh_readings)] }

        it 'ignores row' do
          expect(converter.perform).to be_empty
        end
      end

      context 'with missing date' do
        let(:readings) { [create_reading(config, '12345678', nil, create_hh_readings)] }

        it 'ignores row' do
          expect(converter.perform).to be_empty
        end
      end

      context 'with badly parsed values' do
        let(:readings) { [create_reading(config, 'Primary school', '123456789012', ['01/01/2019'])] }

        it 'raises an error' do
          expect { converter.perform }.to raise_error(ArgumentError)
        end
      end

      context 'with fewer than 48 readings for a day' do
        let(:config) { create(:amr_data_feed_config, :with_positional_index) }

        let(:readings) do
          46.times.collect { |hh| create_reading_for_period(config, '1710035168313', '25/08/2019', (hh + 1).to_s, ['14.4']) }
        end

        it 'rejects the row' do
          expect(converter.perform).to be_empty
        end

        context 'with merging allowed' do
          let(:config) { create(:amr_data_feed_config, :with_positional_index, allow_merging: true) }
          let(:mpan_mprn) { '1710035168313' }
          let(:reading_date) { '26 Aug 2019' }

          let(:readings) do
            44.times.collect { |hh| create_reading_for_period(config, mpan_mprn, reading_date, (hh + 1).to_s, [(hh + 1).to_s]) }
          end

          let(:expected_output) do
            [create_reading(config, mpan_mprn, Date.parse(reading_date), Array.new(48) {|i| i < 44 ? (i + 1).to_f : nil })]
          end

          it 'does not reject the row' do
            expect(converter.perform).to eq(expected_output)
          end
        end
      end
    end

    context 'with more than 48 readings per day' do
      let(:config) { create(:amr_data_feed_config, :with_positional_index) }
      let(:readings) do
        data = []
        49.times { |hh| data << create_reading_for_period(config, '1710035168313', '25/08/2019', (hh + 1).to_s, ['14.4']) }
        48.times { |hh| data << create_reading_for_period(config, '1710035168313', '26/08/2019', (hh + 1).to_s, ['14.4']) }
        data
      end

      subject(:results) { converter.perform }

      it 'truncates after 48 readings' do
        expect(results.first[:readings].length).to be(48)
        expect(results.second[:readings].length).to be(48)
      end
    end

    describe '.convert_time_string_to_usable_time' do
      it 'converts a string of numbers to a valid time string' do
        valid_reading_times.each do |time_string|
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)).to eq(time_string)
        end

        # There's an additional test for possible zero values below so drop the first 2 valid_reading_times
        valid_reading_times.drop(2).each do |time_string|
          time_string_without_colon = time_string.delete(':')
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string_without_colon)).to eq(time_string.rjust(5, '0'))
        end

        %w[0 00 000 0000].each do |time_string|
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)).to eq('00:00')
        end

        expect(Amr::SingleReadConverter.convert_time_string_to_usable_time('30')).to eq('00:30')
      end

      it 'raises an error if a string cannot be converted to a valid time string' do
        valid_reading_times.each do |time_string|
          time_string_as_integer = time_string.to_i
          expect do
            Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string_as_integer)
          end.to raise_error(Amr::SingleReadConverter::InvalidTimeStringError)
        end

        ['abc', 130, 0o130, '24:00', '2400', '12345'].each do |time_string|
          expect do
            Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)
          end.to raise_error(Amr::SingleReadConverter::InvalidTimeStringError)
        end
      end
    end

    describe '.valid_time_string?' do
      it 'returns true if a time string is in a format valid and usable by TimeOfDay parse' do
        valid_reading_times.each do |time_string|
          expect(Amr::SingleReadConverter).to be_valid_time_string(time_string)
        end
        expect(Amr::SingleReadConverter).to be_valid_time_string('00:30:00')
      end

      it 'returns false if a time string is not in a format valid and usable by TimeOfDay parse' do
        ['0', '00', '000', '1', '130', 0, 1, 130, '24:30', '25:00'].each do |time_string|
          expect(Amr::SingleReadConverter).not_to be_valid_time_string(time_string)
        end
      end
    end
  end
end
