module DataFeeds
  class WeatherUndergroundCsvWriter

    def initialize(filename, data, orientation = :landscape)
      @filename = filename
      @data = data
      @orientation = orientation
    end

    def write_csv
      # implemented using file operations as roo & write_xlsx don't seem to support writing csv and spreadsheet/csv have BOM issues on Ruby 2.5
      puts "Writing csv file #{@filename}: #{@data.length} items in format #{@orientation}"
      File.open(@filename, 'w') do |file|
        if @orientation == :landscape
          write_landscape(file)
        else
          write_portrait(file)
        end
      end
    end

  private

    def unique_list_of_dates_from_datetimes(datetimes)
      dates = {}
      datetimes.each do |datetime|
        dates[datetime.to_date] = true
      end
      dates.keys
    end

    def write_landscape(file)
      dates = unique_list_of_dates_from_datetimes(@data.keys)
      dates.each do |date|
        line = date.strftime('%Y-%m-%d') << ','
        (0..47).each do |half_hour_index|
          datetime = Time.zone.local(date.year, date.month, date.day, (half_hour_index / 2).to_i, half_hour_index.even? ? 0 : 30, 0).to_datetime

          if data.key?(datetime)
            if data[datetime].nil?
              line << ','
            else
              line << data[datetime].to_s << ','
            end
          end
        end
        file.puts(line)
      end
    end

    def write_portrait(file)
      line = []
      @data.each do |datetime, value|
        line << datetime.strftime('%Y-%m-%d %H:%M:%S') << ',' << value.to_s << '\n'
        file.puts(line)
      end
    end
  end
end