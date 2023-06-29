module Amr
  class N3rgyDownloaderDates
    def self.start_date(available_range, current_range)
      start = default_start_date
      if available_range
        start = available_range.first
      end
      if current_range && current_range.first <= start
        start = current_range.last
      end

      start = start.change({ hour: 0, min: 0, sec: 0 }) if start.is_a?(DateTime)
      start
    end

    def self.end_date(available_range)
      end_date = available_range ? available_range.last : default_end_date
      end_date = end_date.change({ hour: 23, min: 30, sec: 0 }) if end_date.is_a?(DateTime)
      end_date
    end

    def self.default_start_date
      Time.zone.today - 13.months
    end

    def self.default_end_date
      Time.zone.today - 1
    end
  end
end
