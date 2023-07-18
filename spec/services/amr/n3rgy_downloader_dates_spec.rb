require 'rails_helper'

module Amr
  describe N3rgyDownloaderDates do
    include ActiveSupport::Testing::TimeHelpers

    let(:available_range) { [DateTime.parse('2023-01-01T12:00'), DateTime.parse('2023-02-01T12:00'), DateTime.parse('2023-03-01T12:00')] }
    let(:current_range) { [DateTime.parse('2023-02-01T12:00'), DateTime.parse('2023-03-01T12:00'), DateTime.parse('2023-04-01T12:00')] }

    describe '#start_date' do
      it 'picks the appropriate start date from the available and current range' do
        travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
          expect(Amr::N3rgyDownloaderDates.start_date(available_range, current_range).to_s).to eq('2023-01-01T00:00:00+00:00')
          expect(Amr::N3rgyDownloaderDates.start_date(nil, current_range).to_s).to eq('2022-05-29T00:00:00+00:00') # DateTime now minus 13 months
          expect(Amr::N3rgyDownloaderDates.start_date(available_range, nil).to_s).to eq('2023-01-01T00:00:00+00:00')
        end
      end
    end

    describe '#end_date' do
      it 'picks the appropriate start date from the available and current range' do
        travel_to DateTime.parse('2023-06-29T04:05:06+00:00') do
          expect(Amr::N3rgyDownloaderDates.end_date(available_range).to_s).to eq('2023-03-01T12:00:00+00:00')
          expect(Amr::N3rgyDownloaderDates.end_date(nil).to_s).to eq('2023-06-28T23:30:00+00:00') # DateTime now minus 1 day
        end
      end
    end
  end
end
