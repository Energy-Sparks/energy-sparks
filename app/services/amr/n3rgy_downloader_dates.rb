module Amr
  class N3rgyDownloaderDates
    def self.start_date(available_range, current_range)
      start = default_start_date
      start = available_range.first if available_range
      start = current_range.last if current_range && current_range.first <= start

      start.change({ hour: 0, min: 0, sec: 0 })
    end

    def self.end_date(available_range)
      available_range ? available_range.last : default_end_date
    end

    def self.default_start_date
      (DateTime.now - 13.months).change({ hour: 0, min: 0, sec: 0 })
    end

    def self.default_end_date
      (DateTime.now - 1).change({ hour: 23, min: 30, sec: 0 })
    end
  end
end
