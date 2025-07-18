require 'require_all'
require_relative '../lib/dashboard.rb'
# BATCH Process to download historic UK grid carbon intensity(c) Energy Sparks 2018-
#
# API: https://api.carbonintensity.org.uk/
#
# example url: https://api.carbonintensity.org.uk/intensity/2017-09-18T12:00Z/2017-10-01T12:00Z
#
class DownloadUKGridCarbonIntensity
  include Logging

  def initialize
    @csv_filename = File.join(File.dirname(__FILE__), '../InputData/uk_carbon_intensity.csv')
    @start_date = Date.new(2017, 9, 19) # 2017/9/19 is the first date data available, overwritten if csv exists
    @end_date = Date.today - 1
  end

  # find the final date of data written to csv file, or nil if file doesn;t exist
  def csv_last_reading(filename)
    last_date = nil
    if File.exist?(filename)
      File.open(filename, 'r') do |file|
        last_date = Date.parse(file.readlines.last.split(',')[0])
      end
    end
    last_date
  end

  # save data to file in date, carbon val 0, ..... carbon val 48 - format
  def write_csv(filename, data, append)
    mode = append ? "Appending" : "Writing"
    logger.info "#{mode} csv file #{filename}: #{data.length} items from #{data.keys.first} to #{data.keys.last}"
    File.open(filename, append ? 'a' : 'w') do |file|
      data.each do |date, one_days_values|
        dts = date.strftime('%Y-%m-%d')
        file.puts("#{dts}," + one_days_values.join(','))
      end
    end
  end

  def download
    logger.info '=' * 120
    logger.info 'UK CARBON INTENSITY DOWNLOAD'

    last_reading_date_from_csv = csv_last_reading(@csv_filename)

    if !last_reading_date_from_csv.nil? && last_reading_date_from_csv >= @end_date
      logger.info '    csv file already up to date'
    else
      logger.info "Downloading uk carbon intensity data to #{@csv_filename}"
      @start_date = last_reading_date_from_csv + 1 unless last_reading_date_from_csv.nil?

      day_readings = UKGridCarbonIntensityFeed.new.download(@start_date, @end_date)

      write_csv(@csv_filename, day_readings, !last_reading_date_from_csv.nil?)
    end
  end
end
