require 'require_all'

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
      @logger ||= Logger.new(STDOUT)
    end
  end
end

# Ultimately based on AR models
require_rel '../app/**/*.rb'

# load all ruby files in the directory "lib" and its subdirectories
# require_rel '../lib/dashboard/charting_and_reports/interpret_chart.rb'
require_rel '../lib/dashboard/**/*.rb'

# From gems
require 'logger'
require 'net/http'
require 'json'
require 'date'
require 'amazing_print'

require 'interpolate'
require 'benchmark'
require 'open-uri'
require 'statsample'

require 'active_support'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/numeric/conversions'
require 'active_support/core_ext/object'
require 'active_support/core_ext/time/calculations'

# downloadregionalsolardatafromsheffieldluniversity
# downloadSolarAndTemperatureData
