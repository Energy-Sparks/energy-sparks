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
      (DateTime.now - 13.months).change({ hour: 0, min: 30, sec: 0 })
    end

    # midnight today is the final reading from yesterday
    def self.default_end_date
      DateTime.now.change({ hour: 0, min: 0, sec: 0 })
    end
  end
end
