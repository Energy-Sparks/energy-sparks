# to aid debugging output is distributed between different logfiles and STDOUT
module Logging
  logger.formatter = proc do |severity, datetime, progname, msg|
    case $logger_format
    when 1
      "#{severity.ljust(5, ' ')}: #{msg}\n"
    when 2
      "#{datetime} #{severity.ljust(5, ' ')}: #{msg}\n"
    end
  end

  # https://stackoverflow.com/questions/9971803/dynamically-change-the-logdevice-of-ruby-logger
  class MyIO
    def initialize
      @file = nil
      @history = StringIO.new "", "w"
    end

    def file
      @file
    end

    def file=(filename_or_io)
      @file = filename_or_io.is_a?(IO) ? filename_or_io : File.open(filename_or_io, 'a+')
      @file.write @history.string if @history
      @history = nil
    end

    def write(data)
      @history.write(data) if @history
      @file.write(data) if @file
    end

    def close
      @file.close if @file
    end
  end

  @@es_logger_file = MyIO.new
  @@es_logger_file.file = STDOUT
  @logger = Logger.new(@@es_logger_file)
end