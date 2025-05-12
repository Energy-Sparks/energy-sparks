require 'require_all'
require_relative '../../lib/dashboard.rb'
require_all './test_support/'

module Logging
  @logger = @logger = Logger.new(File.join(TestDirectory.instance.log_directory, 'bulk convert yaml.log'))
  logger.level = :debug
end

#
# its not entirely clear whether the threading speeds things
# up, it is assumed that the conversion is to some extent IO bound
# and therefore some of the IO could happen in parallel
# however, it seems to workload may be CPU bound
#
school_pattern_match = ['*']
source = :unvalidated_meter_data_bulk_load_dont_process
analysis = {}

threads = []
school_list = SchoolFactory.instance.school_file_list(source, school_pattern_match)

school_list.sort.each_slice(50) do |school_names|
  t = Thread.new {
    tt = 0
    puts "New thread for #{school_names.length} schools from #{school_names.first} to #{school_names.last}"
    school_names.each do |school_name|
      puts "Doing #{school_name} #{tt + 1} of #{school_names.length}"
      school = SchoolFactory.instance.load_school(source, school_name)
      tt += 1
    end
  }
  threads.push(t)
end

threads.each { |t| t.join }
