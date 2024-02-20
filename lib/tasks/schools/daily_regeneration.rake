require 'aws-sdk-sqs'

namespace :school do
  desc "Schools daily regeneration"
  task daily_regeneration: :environment do
    puts "#{DateTime.now.utc} Run daily regeneration for all process data schools start"
    client = Aws::SQS::Client.new
    # School.process_data.order(:name).limit(100).
    '1252 1166 732 1134 1060 705 782 504 666 1242 1251 532 943 942 133 964 965 379 1235 332 951 928 910 407 327 1161 359 817 1194 1164 582 583 1273 368 464 549 801 202 598 914 545 1011 646 469 1217 862 344 295 1240 1115 524 388 769 647 731 633 966 360 584 784 585 660 95 1114 1181 876 605 1024 730 1130 232 648 1170 944 1319 1192 941 733 10 586 465 1081 994 990 241 378 505 529 538 781 1221 1219 1026 1178 734 1005 639 1136 735 1007' \
      .split.each_slice(10) do |batch|

      client.send_message_batch({
        queue_url: "https://sqs.eu-west-2.amazonaws.com/110304303563/analytics-pipeline-development-my-queue",
        entries: batch.map { |school_id| { id: school_id, message_body: school_id }}
      })
    end
    # BenchmarkResultGenerationRun.create!
    # School.process_data.order(:name).each do |school|
    #   puts "Run daily regeneration job for #{school.name}"
    #   begin
    #     DailyRegenerationJob.perform_later(school: school)
    #   rescue => e
    #     puts "Exception: running validation for #{school.name}: #{e.class} #{e.message}"
    #     puts e.backtrace.join("\n")
    #     Rails.logger.error "Exception: running validation for #{school.name}: #{e.class} #{e.message}"
    #     Rails.logger.error e.backtrace.join("\n")
    #     Rollbar.error(e, job: :daily_regeneration, school_id: school.id, school: school.name)
    #   end
    # end
    # puts "#{DateTime.now.utc} Run daily regeneration for all process data schools end"
  end
end
