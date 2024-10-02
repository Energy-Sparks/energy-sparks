module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    # If rails is defined, then use that
    if Object.const_defined?('Rails')
      @logger ||= Rails.logger
    else
      # This can be overridden - for example, in a test file you could do
      # module Logging
      #   @logger = Logger.new('log/oggy-mc-logface.log')
      #   logger.level = :debug
      # end
      @logger ||= Logger.new($stdout)
    end
  end
end
