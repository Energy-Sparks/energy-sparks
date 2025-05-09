class HalfHourlyLoader
  include Logging

  def initialize(csv_file, date_column, data_start_column, header_rows, data)
    @data_start_column = data_start_column
    @date_column = date_column
    @header_rows = header_rows
    marshal_file = marshal_filename(csv_file)
    if !File.exist?(marshal_file) || File.mtime(csv_file) > File.mtime(marshal_file)
      load_csv_file_and_save_marshal_file(csv_file, data)
    else
      raw_data = load_marshal_copy(csv_file)
      raw_data.each do |date, row_data_x48|
        data.add(date, row_data_x48)
      end
    end
  end

  private def save_marshal_copy(csv_file, data)
    File.open(marshal_filename(csv_file), 'wb') { |f| f.write(Marshal.dump(data)) }
  end

  private def load_marshal_copy(csv_file)
    data = nil
    filename = marshal_filename(csv_file)
    puts "Loading ? #{filename}"
    if File.exist?(filename)
      bm = Benchmark.realtime {
        data = Marshal.load(File.open(filename))
      }
      logger.info "Loading #{filename} took #{bm.round(5)} to load #{data.length} days of data"
      puts "Loading #{filename} took #{bm.round(5)} to load #{data.length} days of data"
    end
    data
  end

  private def load_csv_file_and_save_marshal_file(csv_file, data)
    bm = Benchmark.realtime {
      read_csv(csv_file, data)
    }
    logger.info "read file  #{csv_file} in #{bm.round(5)}"
    puts "read file  #{csv_file} in #{bm.round(5)}"
    bm = Benchmark.realtime {
      save_marshal_copy(csv_file, data)
    }
    logger.info "saved marshal version inin #{bm.round(5)}"
    puts "saved marshal version in #{bm.round(5)}"
  end

  private def marshal_filename(csv_file)
    Pathname(csv_file).sub_ext('.marshal')
  end

  # about 10 times faster than the Roo version
  def read_csv(csv_file, data)
    logger.info "Reading #{data.type} data from '#{csv_file} date column = #{@date_column} data starts at col #{@data_start_column} skipping #{@header_rows} header rows"
    lines = File.readlines(csv_file)
    (@header_rows...lines.length).each do |i|
      reading = lines[i].split(',')
      begin
        date = Date.parse(reading[@date_column])
        rowdata = reading[@data_start_column, @data_start_column + 47].map(&:to_f)
        data.add(date, rowdata)
      rescue StandardError => e
        logger.warn e.message
        logger.warn e.backtrace.join("\n")
        logger.warn "Unable to read data on line #{i} of file #{csv_file} date value #{reading[@date_column]}"
      end
    end
    logger.info "Read hash #{data.length} rows"
  end

  def read_csv_slow_deprecated(csv_file, data)
    logger.debug "Reading #{data.type} data from '#{csv_file} date column = #{@date_column} data starts at col #{@data_start_column} skipping #{@header_rows} header rows"
    datareadings = Roo::CSV.new(csv_file)
    line_count = 0
    skip_rows = @header_rows
    datareadings.each do |reading|
      line_count += 1
      if skip_rows.zero?
        begin
          date = Date.parse(reading[@date_column])
          rowdata = reading[@data_start_column, @data_start_column + 47]
          rowdata = rowdata.map(&:to_f)
          data.add(date, rowdata)
        rescue StandardError => e
          logger.debug e.message
          logger.debug e.backtrace.join("\n")
          logger.debug "Unable to read data on line #{line_count} of file #{csv_file} date value #{reading[@date_column]}"
        end
      else
        skip_rows -= 1
      end
    end
    logger.debug "Read hash #{data.length} rows"
  end
end
