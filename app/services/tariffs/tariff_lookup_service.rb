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

    def select_tariffs(potential_tariffs, start_date, end_date)
      tariffs = {}
      return tariffs if potential_tariffs.empty?

      potential_tariff = potential_tariffs.first

      #does the first tariff cover the entire period?
      #if so, return that with the dates
      if fully_cover_range?(potential_tariff, start_date, end_date)
        tariffs[potential_tariff] = Range.new(start_date, end_date)
      elsif potential_tariff.end_date < start_date
        #potential ended earlier, so continue looking up hierarchy
        tariffs.merge!(select_tariffs(potential_tariffs[1..], start_date, end_date))
      else
        #otherwise, as this tariff then...
        tariffs[potential_tariff] = Range.new(start_date, potential_tariff.end_date)
        #...iterate with reduced list and updated dates
        tariffs.merge!(select_tariffs(potential_tariffs[1..], potential_tariff.end_date + 1, end_date))
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

    def fully_cover_range?(tariff, start_date, end_date)
      (tariff.start_date.nil? || start_date >= tariff.start_date) && (tariff.end_date.nil? || end_date <= tariff.end_date)
    end
  end
end
