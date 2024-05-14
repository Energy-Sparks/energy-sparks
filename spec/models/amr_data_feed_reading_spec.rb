require 'rails_helper'

describe AmrDataFeedReading do
  describe '.unvalidated_data_report_for_mpans' do
    let(:date_format)   { '%d-%m-%Y' }
    let(:reading_date)  { '28-06-2023' }
    let!(:config)      { create(:amr_data_feed_config, date_format: date_format) }
    let!(:reading)     { create(:amr_data_feed_reading, reading_date: reading_date, amr_data_feed_config: config)}

    let(:results) { AmrDataFeedReading.unvalidated_data_report_for_mpans([reading.mpan_mprn]) }

    it 'returns the expected data' do
      expect(results[0]['mpan_mprn']).to eq reading.mpan_mprn
      expect(results[0]['meter_id']).to eq reading.meter.id
      expect(results[0]['identifier']).to eq config.identifier
      expect(results[0]['description']).to eq config.description
      expect(results[0]['earliest_reading']).to eq Date.new(2023, 6, 28).iso8601
      expect(results[0]['latest_reading']).to eq Date.new(2023, 6, 28).iso8601
    end

    context 'with other date formats' do
      FORMATS = {
        '%d/%m/%Y' => '28/06/2023',
        '%Y-%m-%d' => '2023-06-28',
        '%y-%m-%d' => '23-06-28',
        '%H:%M:%S %a %d/%m/%Y' => '14:00:00 Wed 28/06/2023',
        '%e %b %Y %H:%M:%S' => '28 Jun 2023 14:00:00',
        '%b %e %Y %I:%M%p' => 'Jun 28 2023 02:00pm'
      }.freeze

      FORMATS.each do |format, read_date|
        context "it parses #{format}" do
          let(:date_format)   { format }
          let(:reading_date)  { read_date }

          it { expect(results[0]['latest_reading']).to eq Date.new(2023, 6, 28).iso8601 }
        end
      end
    end

    context 'with incorrectly loaded data' do
      FORMATS = [
        ['%d-%b-%y', '2023-06-28'],
        ['%Y-%m-%d', '28-Jun-23'],
        ['%Y-%m-%d', '28/06/2023'],
        ['%d-%m-%Y', '2023-06-28'],
        ['%e %b %Y %H:%M:%S', '2023-06-28'],
      ].freeze

      FORMATS.each do |format|
        context "it parses #{format[1]} despite format being #{format[0]}" do
          let(:date_format)   { format[0] }
          let(:reading_date)  { format[1] }

          it { expect(results[0]['latest_reading']).to eq Date.new(2023, 6, 28).iso8601 }
        end
      end

      context 'with single digit date' do
        let(:date_format)   { '%d/%m/%Y' }
        let(:reading_date)  { '2-Jun-23' }

        context 'it parses correctly' do
          it { expect(results[0]['latest_reading']).to eq Date.new(2023, 6, 2).iso8601 }
        end
      end
    end
  end
end
