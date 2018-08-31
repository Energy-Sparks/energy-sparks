module DataFeeds
  class WeatherUndergroundCsvWriter
    def initialize(filename, data, orientation = :landscape)
      @filename = filename
      @data = data
      @orientation = orientation
    end

    def write_csv
      # implemented using file operations as roo & write_xlsx don't seem to support writing csv and spreadsheet/csv have BOM issues on Ruby 2.5
      puts "Writing csv file public/downloads/#{@filename}: #{@data.length} items in format #{@orientation}"
      File.open("public/downloads/#{@filename}", 'w') do |file|
        if @orientation == :landscape
          write_landscape(file)
        else
          write_portrait(file)
        end
      end
    end

    def csv_as_array
      if @orientation == :landscape
        format_landscape_data(@data)
      else
        format_portrait_data(@data)
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
      lines = format_landscape_data(@data)
      file.puts(lines)
    end

    def write_portrait(file)
      lines = format_portrait_data(@data)
      file.puts(lines)
    end

    def format_landscape_data(hash_of_readings_and_values)
      dates = unique_list_of_dates_from_datetimes(hash_of_readings_and_values.keys)
      lines = dates.map do |date|
        line = date.strftime('%Y-%m-%d') << ','
        (0..47).each do |half_hour_index|
          datetime = Time.zone.local(date.year, date.month, date.day, (half_hour_index / 2).to_i, half_hour_index.even? ? 0 : 30, 0).to_datetime.utc
          if hash_of_readings_and_values.key?(datetime)
            if hash_of_readings_and_values[datetime].nil?
              line << ','
            else
              line << hash_of_readings_and_values[datetime].to_s << ','
            end
          end
        end
        line
      end
      lines.join("\n")
    end

    def format_portrait_data(hash_of_readings_and_values)
      output = hash_of_readings_and_values.map do |datetime, value|
        "#{datetime.strftime('%Y-%m-%d %H:%M:%S')}, #{value}"
      end
      output.join("\n")
    end
  end
end
