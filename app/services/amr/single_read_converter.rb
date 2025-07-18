module Amr
  class SingleReadConverter
    class InvalidTimeStringError < StandardError; end

    # @param AmrDataFeedConfig amr_data_feed_config the data feed configuration used to customise processing
    # @param Array single_reading_array an array of readings
    def initialize(amr_data_feed_config, single_reading_array)
      @amr_data_feed_config = amr_data_feed_config
      @single_reading_array = single_reading_array
      @results_array = []
    end

    # Reading will be in one of the following formats:
    #
    # * With timestamps, which may be based on labelling either the start or the end of the half-hourly period
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
    #
    # The bulk of the code here is about building an array of x48 readings from each individual readings,
    # ensuring the right array indexes are used based on correctly interpreting the above. Internally we label
    # HH periods from the start of the half hour.
    #
    # Mapping from numbers periods is simple, for the others formats we have to interpret the time or timestamps correctly
    def perform
      @single_reading_array.each do |reading|
        # ignore rows that dont have necessary information
        next unless reading[:reading_date].present? && reading[:mpan_mprn].present?

        reading_date = parse_reading_date(reading)

        kwh = reading[:readings].first.to_f

        reading_index = reading_index_of_record(reading)
        next if reading_index.nil?

        this_day = day_from_results(reading_date, reading[:mpan_mprn])

        if this_day.present?
          this_day[:readings][reading_index] = kwh
        else
          readings = Array.new(48)
          readings[reading_index] = kwh
          new_record = { reading_date:, readings:, mpan_mprn: reading[:mpan_mprn], amr_data_feed_config_id: reading[:amr_data_feed_config_id], meter_id: reading[:meter_id] }
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
      # As well as with optional secs, e.g. '00:30:00'
      time_string.match?(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:00)?$/)
    end

    private

    def truncate_too_many_readings
      @results_array.each { |result| result[:readings] = result[:readings].take(48) if result[:readings].count > 48 }
    end

    def reject_any_low_reading_days
      return @results_array if @amr_data_feed_config.allow_merging
      @results_array.reject { |result| result[:readings].count(&:blank?) > @amr_data_feed_config.blank_threshold }
    end

    def day_from_results(reading_day, mpan_mprn)
      @results_array.find { |result| result[:reading_date] == reading_day && result[:mpan_mprn] == mpan_mprn }
    end

    # Parses the reading date. When using a timestamp with readings labelled at the end of the half-hourly period
    # we need to adjust the date as 2024-10-10T00:00:00Z should be usage from 2024-10-09 23:30.
    def parse_reading_date(reading)
      if indexed_with_period? || indexed_by_time? || half_hourly_labelling_at_start?
        Date.parse(reading[:reading_date])
      else
        reading_day_time = Time.zone.parse(reading[:reading_date])
        raise Date::Error.new(reading[:reading_date]) if reading_day_time.nil?
        # roll the date backward for last reading of day
        reading_day_time == reading_day_time.midnight ? (reading_day_time - 1.day).to_date : reading_day_time.to_date
      end
    end

    # Find array index for this reading
    def reading_index_of_record(reading)
      if indexed_with_period?
        index_from_period(reading)
      elsif indexed_by_time?
        index_from_time_field(reading)
      elsif half_hourly_labelling_at_start?
        index_from_timestamps_at_start_of_half_hour(reading)
      else
        index_from_timestamps_at_end_of_half_hour(reading)
      end
    end

    def indexed_with_period?
      @amr_data_feed_config[:positional_index] && @amr_data_feed_config[:period_field]
    end

    def indexed_by_time?
      @amr_data_feed_config[:positional_index] && @amr_data_feed_config[:reading_time_field]
    end

    def half_hourly_labelling_at_start?
      @amr_data_feed_config.half_hourly_labelling&.to_sym == :start
    end

    # Periods are numbered 1-48
    def index_from_period(reading)
      reading[:period].to_i - 1
    end

    # Reformat the reading time into %H:%M format and calculate index
    def index_from_time_field(reading)
      time_string = SingleReadConverter.convert_time_string_to_usable_time(reading[:reading_time])
      TimeOfDay.parse(time_string).to_halfhour_index
    end

    # Parse the reading time stamp using configured format, then extract just the time to calculate index
    def index_from_timestamps_at_start_of_half_hour(reading)
      reading_day_time = Time.strptime(reading[:reading_date], @amr_data_feed_config.date_format)
      time_string = reading_day_time.strftime('%H:%M')
      TimeOfDay.parse(time_string).to_halfhour_index
    end

    def index_from_timestamps_at_end_of_half_hour(reading)
      reading_day_time = Time.zone.parse(reading[:reading_date])
      time_string = reading_day_time == reading_day_time.midnight ? '23:30' : reading_day_time.advance(minutes: -30).strftime('%H:%M')
      TimeOfDay.parse(time_string).to_halfhour_index
    end
  end
end
