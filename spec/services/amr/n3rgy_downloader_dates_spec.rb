require 'rails_helper'

module Amr
  describe N3rgyDownloaderDates do
    include ActiveSupport::Testing::TimeHelpers

    let(:available_range) { [DateTime.parse('2023-01-01T00:30'), DateTime.parse('2023-02-01T00:00')] }
    let(:current_range) { [DateTime.parse('2023-02-01T12:00'), DateTime.parse('2023-03-01T12:00')] }

    describe '#start_date' do
      context 'when n3rgy available data is earlier than our range' do
        it 'uses the n3rgy available data range' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            expect(described_class.start_date(available_range, current_range).to_s).to eq('2023-01-01T00:30:00+00:00')
          end
        end
      end

      context 'when there is no n3rgy available range' do
        it 'uses our range' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            # DateTime now minus 13 months
            expect(described_class.start_date(nil, current_range).to_s).to eq('2022-05-29T00:30:00+00:00')
          end
        end
      end

      context 'when there is no data in our system' do
        it 'uses the n3rgy range' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            expect(Amr::N3rgyDownloaderDates.start_date(available_range, nil).to_s).to eq('2023-01-01T00:30:00+00:00')
          end
        end
      end
    end

    describe '#end_date' do
      context 'when there are dates from n3rgy' do
        it 'uses their end date' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            expect(Amr::N3rgyDownloaderDates.end_date(available_range).to_s).to eq('2023-02-01T00:00:00+00:00')
          end
        end
      end

      context 'when there are no n3rgy dates' do
        it 'uses a default date' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            # midnight today
            expect(Amr::N3rgyDownloaderDates.end_date(nil).to_s).to eq('2023-06-29T00:00:00+00:00')
          end
        end
      end

      context 'when n3rgy returns a future date' do
        let(:available_range) { [DateTime.parse('2023-01-01T00:30'), DateTime.parse('2023-06-29T23:30')] }

        it 'uses a default date' do
          travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
            # midnight today
            expect(Amr::N3rgyDownloaderDates.end_date(nil).to_s).to eq('2023-06-29T00:00:00+00:00')
          end
        end
      end
    end
  end
end
