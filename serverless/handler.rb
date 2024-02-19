# frozen_string_literal: true

# require 'bundler'
# Bundler.setup(:default)

# puts("LD_LIBRARY_PATH #{ENV['LD_LIBRARY_PATH']}")

# puts(`ldd /opt/ruby/3.2.0/gems/pg-1.5.4/lib/pg_ext.so`)
# puts(Dir.entries('/usr/lib64/'))
# puts(Dir.entries('/opt/lib/'))

# require_relative 'config/boot'
require 'active_support'
# based on
# https://github.com/rails/rails/blob/f5910f74d4a3a8c4af3ab5216dd0c09ce03f086a/railties/lib/rails/application.rb#L586
ActiveSupport.on_load(:before_initialize) { config.eager_load = false }
require_relative 'config/environment.rb'

# require_relative "config/boot"
# require_relative 'config/application'
# require "rake"
# Rake.application.run

require 'cgi'
require 'logger'

def run(event:, context:)
  # s3_record = event['Records'].first['s3']
  # file_key = CGI.unescape(s3_record['object']['key'])
  # bucket_name = s3_record['bucket']['name']

  logger = Logger.new($stdout)

  # logger.info("Running with file: #{file_key} from bucket: #{bucket_name}")
  logger.debug("Event: #{event}")
  logger.debug("Context: #{context}")

  client = Aws::SQS::Client.new

  event['Records'].each do |message|
    school = School.find(message['body'])
    logger.info("Running with school #{school.id}")
    Schools::SchoolRegenerationService.new(school: school).perform
    # logger.info("tmp #{Dir.glob('/tmp/**/*')}")
    ret = client.delete_message({ queue_url: ENV['QUEUE_URL'], receipt_handle: message['receiptHandle'] })
    # logger.info("delete #{ret}")
  end

  # school = School.find_by(slug: 'king-james-1-community-academy')
  # school = School.find(127)
  # Schools::SchoolRegenerationService.new(school: school).perform
end

# run(event: {}, context: {})

# School.find(127)
