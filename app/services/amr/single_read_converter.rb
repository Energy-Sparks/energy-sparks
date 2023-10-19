module Amr
  class SingleReadConverter
    class MissingIndexKeyError < StandardError; end
    BLANK_THRESHOLD = 1
    READING_TIMES = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"].freeze

    #@param Array single_reading_array an array of readings
    #@param boolean indexed whether the array should be interpreted in HH order, rather than via timestamp.
    def initialize(single_reading_array, indexed: false)
      @single_reading_array = single_reading_array
      @indexed = indexed
      @results_array = []
    end

    #Reading will be in formats:
    #
    # With timestamps starting at 00:00:00 or 00:30:00 e.g.:
    #  {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]
    #
    # With reading date and reading time split to 2 fields with timestamps starting at 00:00:00 or 00:30:00 e.g.:
    #  {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]
    #
    # `indexed: true`, with a named period number field e.g.:
    #
    #  {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :period=> 1, :readings=>["14.4"]
    #  {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :period=> 2, :readings=>["14.4"]
    #
    # ...where each consecutive reading is a new HH period
    # For here we need to determine the period by counting the index into the array
    def perform
      @single_reading_array.each do |single_reading|
        #ignore rows that dont have necessary information
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
        period = if single_reading.key?(:period)
                   single_reading[:period]
                 elsif single_reading.key?(:reading_time)
                   SingleReadConverter::READING_TIMES.index(single_reading[:reading_time]) + 1
                 else
                   raise MissingIndexKeyError
                 end

        period.nil? ? nil : period.to_i - 1
      else
        reading_day_time = Time.parse(single_reading[:reading_date]).utc
        first_reading_time = Time.parse(reading_day.strftime('%Y-%m-%d')).utc + 30.minutes

        ((reading_day_time - first_reading_time) / 30.minutes).to_i
      end
    end

    def day_from_results(reading_day, mpan_mprn)
      @results_array.find { |result| result[:reading_date] == reading_day && result[:mpan_mprn] == mpan_mprn }
    end
  end
end
