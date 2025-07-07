# frozen_string_literal: true

module Aggregation
  class ValidateAmrData
    module Corrections
      class Rescaler
        def initialize(amr_data, mpan_mprn)
          @amr_data = amr_data
          @mpan_mprn = mpan_mprn
        end

        def perform(start_date:, end_date:, scale:)
          # case where another correction has changed data prior to configured correction
          rescale_start_date = rescale_start_date(start_date)
          rescale_end_date = rescale_end_date(end_date)
          (rescale_start_date..rescale_end_date).each do |date|
            next unless @amr_data.date_exists?(date) && @amr_data.substitution_type(date) != 'S31M'

            new_data_x48 = []
            (0..47).each do |halfhour_index|
              new_data_x48.push(@amr_data.kwh(date, halfhour_index) * scale)
            end
            scaled_data = OneDayAMRReading.new(@mpan_mprn, date, 'S31M', nil, DateTime.now, new_data_x48)
            @amr_data.add(date, scaled_data)
          end
          @amr_data
        end

        private

        def rescale_start_date(start_date)
          return @amr_data.start_date if start_date.nil? || @amr_data.start_date > start_date

          start_date
        end

        def rescale_end_date(end_date)
          # ensure that we dont loop forever if an end date isn't provided
          return @amr_data.end_date if end_date.nil? || @amr_data.end_date < end_date

          end_date
        end
      end
    end
  end
end
