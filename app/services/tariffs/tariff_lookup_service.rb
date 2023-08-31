module Tariffs
  class TariffLookupService
    def initialize(school:, meter_type: :electricity, meter: nil)
      @school = school
      @meter_type = meter_type
      @meter = meter
    end

    def find_tariffs_between_dates(start_date, end_date)
      potential_tariffs = potential_tariffs(start_date, end_date)
      select_tariffs(potential_tariffs, start_date, end_date)
    end

    def tariffs_changed_between_dates?(start_date, end_date)
    end

    private

    #TODO sorting
    def select_tariffs(potential_tariffs, start_date, end_date)
      tariffs = {}
      return tariffs if potential_tariffs.empty?

      potential_tariff = potential_tariffs.first

      if outside_range?(potential_tariff, start_date, end_date)
        #tariff doesnt align with dates we need so continue looking
        tariffs.merge!(select_tariffs(potential_tariffs[1..], start_date, end_date))
      elsif fully_cover_range?(potential_tariff, start_date, end_date)
        #tariff covers entire range, so we're done
        tariffs[potential_tariff] = Range.new(start_date, end_date)
      else
        #...iterate with reduced list and updated dates

        #Cover the first part of the range
        if (potential_tariff.start_date.nil? || potential_tariff.start_date <= start_date) && potential_tariff.end_date <= end_date
          #in which case add that, then continue looking with end of range dates
          tariffs[potential_tariff] = Range.new(start_date, potential_tariff.end_date)
          tariffs.merge!(select_tariffs(potential_tariffs[1..], potential_tariff.end_date + 1, end_date))
        end
        #Cover the last part of the range
        if potential_tariff.start_date > start_date && potential_tariff.end_date > end_date
          #in which case add that, then continue looking with start of range dates
          tariffs[potential_tariff] = Range.new(potential_tariff.start_date, end_date)
          #TODO need earliest date available?
          tariffs.merge!(select_tariffs(potential_tariffs[1..], nil, potential_tariff.start_date))
        end
        #Cover the middle of the range
        if potential_tariff.start_date > start_date && potential_tariff.end_date < end_date
          #in which case add that and look for first and last part of the ranges
          tariffs[potential_tariff] = Range.new(potential_tariff.start_date, potential_tariff.end_date)
          #split range, call select twice
          #tariffs.merge!(select_tariffs(potential_tariffs[1..], potential_tariff.end_date + 1, end_date))
        end
      end
      tariffs
    end

    def potential_tariffs(start_date, end_date)
      potential_tariffs = @school.all_tariffs_within_dates(@meter_type, start_date, end_date)
      if @meter.present?
        potential_tariffs.delete_if do |tariff|
          tariff.tariff_holder == @school && !tariff.meters.include?(@meter)
        end
      end
      potential_tariffs
    end

    def outside_range?(tariff, start_date, _end_date)
      tariff.end_date.present? && tariff.end_date < start_date
    end

    def fully_cover_range?(tariff, start_date, end_date)
      (tariff.start_date.nil? || start_date >= tariff.start_date) && (tariff.end_date.nil? || end_date <= tariff.end_date)
    end
  end
end
