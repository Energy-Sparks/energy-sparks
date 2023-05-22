module Amr
  class SingleReadConverter
    BLANK_THRESHOLD = 1

    #@param Array single_reading_array an array of readings
    #@param boolean indexed whether the array should be interpreted in HH order, rather than via timestamp
    def initialize(single_reading_array, indexed: false)
      @single_reading_array = single_reading_array
      @indexed = indexed
      @results_array = []
    end

    #Reading will be either:
    #
    #{:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]
    #
    # With timestamps starting at 00:00:00 or 00:30:00
    #
    # OR (indexed: true)
    #
    #{:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :readings=>["14.4"]
    #{:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019", :readings=>["14.4"]
    #
    # ...where each consecutive reading is a new HH period
    # For here we need to determine the period by counting the index into the array
    def perform
      current_mpan_mprn = nil
      mpan_mprn_reading_count = 0

      @single_reading_array.each do |single_reading|
        #track which mpan we are processing. code assumes all readings for a
        #meter are in a single block
        if single_reading[:mpan_mprn] != current_mpan_mprn
          current_mpan_mprn = single_reading[:mpan_mprn]
          @dates = Set.new
          mpan_mprn_reading_count = 0
        end

        #keep a count of number of unique days for each mpan
        @dates.add(single_reading[:reading_date])

        reading_day = Date.parse(single_reading[:reading_date])
        reading = single_reading[:readings].first.to_f

        reading_index = reading_index_of_record(reading_day, single_reading, mpan_mprn_reading_count)

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

        #update reading count for this mpan
        mpan_mprn_reading_count += 1
      end

      reject_any_low_reading_days
    end

    private

    def reject_any_low_reading_days
      @results_array.reject { |result| result[:readings].count(&:blank?) > BLANK_THRESHOLD }
    end

    def last_reading_of_day?(reading_index)
      reading_index == -1
    end

    def reading_index_of_record(reading_day, single_reading, index)
      if @indexed
        index < 48 ? index : index - ((@dates.size - 1) * 48)
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
