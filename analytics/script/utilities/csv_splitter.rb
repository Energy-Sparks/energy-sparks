# splits a large csv file into multiple smaller files
# grouped on the defined header column name
# developed to split Bath full.csv 210MB file into indivdual schools by postcode

class CSVSplitter
  def initialize(source_file, destination_directory, split_column_name, delimiter)
    @source_file = source_file
    @destination_directory = destination_directory
    @split_column_name = split_column_name
    @delimiter = delimiter
  end

  def split
    puts "Downloading data from #{@source_file}"
    @file = File.open(@source_file)
    read_header
    @split_column_number = @column_names.index(@split_column_name)
    load_data_and_group
    # data_statistics
    save_files
  end

  def read_header
    @original_header = @file.readline
    @column_names = @original_header.gsub('"', '').split(@delimiter)
  end

  def load_data_and_group
    count = 0
    @data = {}  # hash split on column_name to array of lines
    @file.each do |line|
      count += 1
      split_col_data = line.gsub('"', '').split(@delimiter)[@split_column_number]
      @data[split_col_data] = [] unless @data.key?(split_col_data)
      @data[split_col_data].push(line)
    end
    puts "Downloaded #{count} lines"
  end

  def save_files
    @data.each do |key, lines|
      if key.nil?
        puts "Error: nil key, skipping save"
        next
      end
      filename = new_filename(key)
      puts "Saving #{filename}"
      File.open(filename, 'w') do |f|
        f.write(@original_header)
        lines.each do |line|
          f.write(line)
        end
      end
    end
  end

  def new_filename(key)
    @destination_directory + '\meter-amr-readings-' + key + '.csv'
  end

  def data_statistics
    @data.each do |key, lines|
      puts "#{key} #{lines.length}"
    end
  end
end

destination_directory = 'C:\\Users\\phili\\OneDrive\\ESDev\\energy-sparks_analytics\\MeterReadings\\Front End CSV Downloads\\'
source_file = destination_directory + 'all-amr-validated-readings.csv'

splitter = CSVSplitter.new(source_file, destination_directory,'Mpan Mprn', ',')

splitter.split

