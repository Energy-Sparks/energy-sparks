class TestCSVFileSupport
  include Logging

  def initialize(filename, path = '../InputData/')
    @path = path
    @backup_path = @path + 'Backup/'
    @filename = filename
    @backup_filename = construct_backup_filename
  end

  def exists?
    File.exist?(full_filename)
  end

  def backup
    logger.info "copying from #{full_filename} to #{@backup_filename}"
    FileUtils.cp(full_filename, @backup_filename) if exists?
  end

  def last_reading_date
    last_date = nil
    if exists?
      File.open(full_filename, 'r') do |file|
        last_date = Date.parse(file.readlines.compact.last.split(',')[0])
      end
    end
    last_date
  end

  def append_lines_and_close(lines)
    mode = exists? ?  'Appending' : 'Writing'
    logger.info "#{mode} #{lines.length} lines to #{@filename}"
    File.open(full_filename, exists? ? 'a' : 'w') do |file|
      lines.each do |date, one_days_values|
        dts = date.strftime('%Y-%m-%d')
        file.puts("#{dts}," + one_days_values.join(','))
      end
    end
  end

  def file_exists?
  end

  private def full_filename
    File.join(File.dirname(__FILE__), @path) + @filename
  end

  private def construct_backup_filename
    File.join(File.dirname(__FILE__),  @backup_path) + @filename.gsub(/\.csv/, ' ').to_s + 'backup ' + Time.now.strftime('%Y%b%d %H%M') + '.csv'
  end
end