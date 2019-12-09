module Amr
  class SingleReadConverter
    BLANK_THRESHOLD = 1

    def initialize(single_reading_array)
      @single_reading_array = single_reading_array
      @results_array = []
    end

    def perform
      @single_reading_array.each do |single_reading|
        reading_day = Date.parse(single_reading[:reading_date])
        reading = single_reading[:readings].first.to_f

        reading_index = reading_index_of_record(reading_day, single_reading)

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

      reject_any_low_reading_days
    end

    private

    def reject_any_low_reading_days
      @results_array.reject { |result| result[:readings].count(&:blank?) > BLANK_THRESHOLD }
    end

    def last_reading_of_day?(reading_index)
      reading_index == -1
    end

    def reading_index_of_record(reading_day, single_reading)
      reading_day_time = Time.parse(single_reading[:reading_date]).utc
      first_reading_time = Time.parse(reading_day.strftime('%Y-%m-%d')).utc + 30.minutes

      ((reading_day_time - first_reading_time) / 30.minutes).to_i
    end

    def day_from_results(reading_day, mpan_mprn)
      @results_array.find { |result| result[:reading_date] == reading_day && result[:mpan_mprn] == mpan_mprn }
    end
  end
end
