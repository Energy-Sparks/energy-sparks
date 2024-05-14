module Amr
  class SingleReadConverter
    class InvalidTimeStringError < StandardError; end

    BLANK_THRESHOLD = 1

    # @param Array single_reading_array an array of readings
    # @param boolean indexed whether the array should be interpreted in HH order, rather than via timestamp.
    def initialize(single_reading_array, indexed: false)
      @single_reading_array = single_reading_array
      @indexed = indexed
      @results_array = []
    end

    # Reading will be in one of the following formats:
    #
    # * With timestamps starting at 00:00:00 or 00:30:00 e.g.:
    #     {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]
    #
    # * With `indexed: true` and reading date and reading time split to 2 fields with timestamps starting at 00:00:00 or 00:30:00 e.g.:
    #     {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :reading_time=>'12:30', :readings=>["14.4"]
    #
    # * With `indexed: true`, with a named period number field e.g.:
    #     {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :period=>1, :readings=>["14.4"]
    #     {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :period=>2, :readings=>["14.4"]
    #
    # ...where each consecutive reading is a new HH period
    # For here we need to determine the period by counting the index into the array
    def perform
      @single_reading_array.each do |single_reading|
        # ignore rows that dont have necessary information
        next unless single_reading[:reading_date].present? && single_reading[:mpan_mprn].present?

        reading_day = Date.parse(single_reading[:reading_date])

        reading = single_reading[:readings].first.to_f

        reading_index = reading_index_of_record(reading_day, single_reading)
        next if reading_index.nil?

        if last_reading_of_day?(reading_index)
          reading_day = reading_day - 1.day
          reading_index = 47
        end

        this_day = day_from_results(reading_day, single_reading[:mpan_mprn])

        if this_day.present?
          this_day[:readings][reading_index] = reading
        else
          readings = Array.new(48)
          readings[reading_index] = reading
          new_record = { reading_date: reading_day, readings: readings, mpan_mprn: single_reading[:mpan_mprn], amr_data_feed_config_id: single_reading[:amr_data_feed_config_id], meter_id: single_reading[:meter_id] }
          @results_array << new_record
        end
      end

      truncate_too_many_readings
      reject_any_low_reading_days
    end

    def self.convert_time_string_to_usable_time(time_string)
      raise Amr::SingleReadConverter::InvalidTimeStringError, "Invalid time string: #{time_string} is a #{time_string.class}" unless time_string.is_a?(String)
      return time_string if valid_time_string?(time_string)

      # Returns time_string right justified and padded with '0'
      # e.g. '0' is converted to "0000", '30' is converted to '0030', and '2330' remains '2330'
      time_string = time_string.rjust(4, '0')
      # Inserts a colon into the time string so it is in a valid format
      # e.g. '0130' is converted to '01:30' and '2330' is converted to '23:30'
      time_string.insert(-3, ':')

      if valid_time_string?(time_string)
        time_string
      else
        raise Amr::SingleReadConverter::InvalidTimeStringError, "Invalid time string: #{time_string} is a #{time_string.class}"
      end
    end

    def self.valid_time_string?(time_string)
      return false unless time_string.is_a?(String)
      # Regex matches time formats with and without leading zero (e.g. '1:30' & '01:30') from '0:00' to '23:59'
      time_string.match?(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    end

    private

    def truncate_too_many_readings
      @results_array.each { |result| result[:readings] = result[:readings].take(48) if result[:readings].count > 48 }
    end

    def reject_any_low_reading_days
      @results_array.reject { |result| result[:readings].count(&:blank?) > BLANK_THRESHOLD }
    end

    def last_reading_of_day?(reading_index)
      reading_index == -1
    end

    def reading_index_of_record(reading_day, single_reading)
      if @indexed
        reading_row_index_for(single_reading)
      else
        reading_day_time_for(reading_day, single_reading)
      end
    end

    def day_from_results(reading_day, mpan_mprn)
      @results_array.find { |result| result[:reading_date] == reading_day && result[:mpan_mprn] == mpan_mprn }
    end

    def reading_day_time_for(reading_day, single_reading)
      reading_day_time = Time.parse(single_reading[:reading_date]).utc
      first_reading_time = Time.parse(reading_day.strftime('%Y-%m-%d')).utc + 30.minutes

      ((reading_day_time - first_reading_time) / 30.minutes).to_i
    end

    def reading_row_index_for(single_reading)
      return single_reading[:period].to_i - 1 if single_reading[:period]

      time_string = SingleReadConverter.convert_time_string_to_usable_time(single_reading[:reading_time])
      TimeOfDay.parse(time_string).to_halfhour_index
    end
  end
end
