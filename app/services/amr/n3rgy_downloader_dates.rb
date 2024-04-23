module Amr
  class N3rgyDownloaderDates
    def self.start_date(available_range, current_range)
      start = default_start_date
      if available_range.present?
        start = available_range.first
      end
      if current_range && current_range.first <= start
        start = current_range.last
      end
      # ensure we're requesting the first reading of that day
      start.change({ hour: 0, min: 30, sec: 0 })
    end

    def self.end_date(available_range)
      candidate_end_date = available_range.present? ? available_range.last : default_end_date
      # encountered a data problem at n3rgy where availableCacheRange had a future date
      candidate_end_date >= Time.zone.today ? default_end_date : candidate_end_date
    end

    # 13 months ago, starting at 00:30 which is 1st reading from n3rgy API
    def self.default_start_date
      self.n3rgy_first_reading_of_day(DateTime.now - 13.months)
    end

    # midnight today is the final reading from yesterday
    def self.default_end_date
      self.n3rgy_last_reading_of_day(DateTime.now)
    end

    # n3rgy uses 00:30 as the first half-hourly reading for a day
    # so convert the date to a date time and set the time accordingly
    def self.n3rgy_first_reading_of_day(date_time)
      date_time.change(hour: 0, min: 30, sec: 0)
    end

    # the last half-hourly reading for a day in the n3rgy API is
    # midnight of the following day.
    #
    # so convert date to a date time and set time accordingly
    def self.n3rgy_last_reading_of_day(date_time)
      date_time.change(hour: 0, min: 0, sec: 0)
    end
  end
end
