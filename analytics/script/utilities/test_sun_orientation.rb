# test sun orientation for solar PV synthetic generation code analysis
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require 'date'
require 'csv'

def save_csv(filename, results)
  puts "Saving to #{filename}"
  CSV.open(filename, 'w' ) do |csv|
    results.each do |location, years_data|
      years_data.each do |month, days_data|
        csv << [location, month, days_data.values].flatten
      end
    end
  end
end

def calculate_azimuths(locations, dates, hours)
  time_zone_hour_offset = 0

  results = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

  locations.each do |town, lat_long|
    puts town
    dates.each do |date|
      hours.each do |hour|
        dt = DateTime.new(date.year, date.month, date.day, hour, 0)
        ll = SunAngleOrientation.angle_orientation(dt, lat_long[:latitude], lat_long[:longitude], time_zone_hour_offset)
        results[town][date][hour] = ll[:solar_azimuth_degrees]
      end
    end
  end

  results
end

locations = {
  penzance:   { latitude: 50.1188, longitude: -5.5376 },
  bath:       { latitude: 51.3781, longitude: -2.3597 },
  felixstowe: { latitude: 51.9617, longitude:  1.3513 },
  thurso:     { latitude: 58.5936, longitude: -3.5221 },
  mallaig:    { latitude: 57.0038, longitude: -5.8272 }
}

dates = (1..12).to_a.map { |m| Date.new(2023, m, 15) }

hours = (0..23).to_a

results = calculate_azimuths(locations, dates, hours)

save_csv('../azimuths_versus_lat_long.csv', results)

ap results
