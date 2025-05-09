# frozen_string_literal: true

require 'sun_times'

module Utilities
  module SunTimes
    def self.criteria(datetime, latitude, longitude, margin_hours)
      sun_times = ::SunTimes.new

      sunrise = sun_times.rise(datetime, latitude, longitude)
      sunrise_criteria = sunrise + (60 * 60 * margin_hours)

      sunset = sun_times.set(datetime, latitude, longitude)
      sunset_criteria = sunset - (60 * 60 * margin_hours)

      [sunrise_criteria, sunset_criteria]
    end

    def self.nighttime_half_hours(date, meter_collection, margin_hours = -1.5)
      sunrise_criteria, sunset_criteria =
        criteria(date, meter_collection.latitude, meter_collection.longitude, margin_hours)
      hh_sunrise = DateTimeHelper.half_hour_index(sunrise_criteria)
      hh_sunset = DateTimeHelper.half_hour_index(sunset_criteria)
      nighttime_hh = Array.new(hh_sunrise, true) + Array.new(hh_sunset - hh_sunrise, false)
      nighttime_hh += Array.new(48 - nighttime_hh.length, true)
      nighttime_hh
    end

    def self.zero_night_hours(date, meter_collection, reading)
      modified = false
      Utilities::SunTimes.nighttime_half_hours(date, meter_collection).each.with_index do |night, hh_i|
        if night && reading[hh_i] != 0.0
          reading[hh_i] = 0.0
          modified = true
        end
      end
      modified
    end
  end
end
