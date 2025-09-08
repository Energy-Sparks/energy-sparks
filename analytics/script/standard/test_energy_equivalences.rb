# test report manager
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel './../../test_support'
require './script/report_config_support.rb'

module Logging
  @logger = Logger.new('log/test-equivalances ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

overrides = {
  schools:  ['k*']
}

script = RunEquivalences.default_config.deep_merge(overrides)

RunTests.new(script).run
