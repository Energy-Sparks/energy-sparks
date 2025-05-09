# test report manager
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require './script/report_config_support.rb'

module Logging
  @logger = Logger.new(File.join('log', 'management summary table.log'))
  logger.level = Logger::DEBUG
end

overrides = {
  schools:  ['coed*'],
  cache_school: false
}

script = RunManagementSummaryTable.default_config.deep_merge(overrides)

RunTests.new(script).run

