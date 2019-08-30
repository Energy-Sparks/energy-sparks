module Amr
  class SingleReadConverter
    def initialize(single_reading_array)
      @single_reading_array = single_reading_array
    end

    def perform
      super_results_array = []

      @single_reading_array.each do |single_reading|
        reading_day = Date.parse(single_reading[:reading_date])
        reading_day_time = Time.parse(single_reading[:reading_date]).utc
        first_reading_time = Time.parse(reading_day.strftime('%Y-%m-%d')).utc + 30.minutes
        reading_index = ((reading_day_time - first_reading_time) / 30.minutes).to_i

        if reading_index == -1
          reading_day = reading_day - 1.day
          reading_index = 47
        end

        this_day = super_results_array.find { |result| result[:reading_date] == reading_day && result[:mpan_mprn] == single_reading[:mpan_mprn] }
        reading = single_reading[:readings].first.to_f

        if this_day.present?
          this_day[:readings][reading_index] = reading
        else
          readings = Array.new(48)
          readings[reading_index] = reading
          new_record = { reading_date: reading_day, readings: readings, mpan_mprn: single_reading[:mpan_mprn], amr_data_feed_config_id: single_reading[:amr_data_feed_config_id] }
          super_results_array << new_record
        end
      end

      super_results_array
    end
  end
end
