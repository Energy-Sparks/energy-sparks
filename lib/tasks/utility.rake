namespace :utility do
  desc 'Stop raises error if automated emails are not turned on'
  task :check_automated_emails_on do
    top_level_tasks = Rake.application.top_level_tasks
    remaining_tasks = top_level_tasks.slice(top_level_tasks.index("utility:check_automated_emails_on") + 1..-1)
    abort("Aborting tasks #{remaining_tasks}: SEND_AUTOMATED_EMAILS is not set") unless ENV['SEND_AUTOMATED_EMAILS']
  end

  desc 'Prepare test server'
  task prepare_test_server: :environment do
    unless ENV['SEND_AUTOMATED_EMAILS']
      puts "Removing non Energy Sparks email addresses and mobile numbers"
      Contact.where.not(email_address: "hello@energysparks.uk").update_all(email_address: '', mobile_phone_number: '')
    end
  end

  desc 'Clear active storage bucket'
  task clear_active_storage_bucket: :environment do
    target_bucket = ENV['AWS_S3_ACTIVE_STORAGE_BUCKET']
    abort("No S3 bucket configure") if target_bucket.blank?
    abort("Cannot be run against production buckets") if target_bucket.include?('prod')
    s3_client = Aws::S3::Client.new
    s3_client.list_objects_v2(bucket: target_bucket).contents.each do |object|
      puts "Deleting #{object.key} from #{target_bucket}"
      s3_client.delete_object(bucket: target_bucket, key: object.key)
    end
  end

  desc 'copy active storage bucket'
  task :copy_active_storage_bucket, [:source_bucket] => [:environment] do |t, args|
    target_bucket = ENV['AWS_S3_ACTIVE_STORAGE_BUCKET']
    source_bucket = args[:source_bucket]
    abort("No S3 target bucket configured") if target_bucket.blank?
    abort("Pass in a source bucket to copy_from") if source_bucket.blank?
    s3_client = Aws::S3::Client.new
    s3_client.list_objects_v2(bucket: source_bucket).contents.each do |object|
      puts "Copying #{object.key} from #{source_bucket} to #{target_bucket}"
      s3_client.copy_object(bucket: target_bucket, copy_source: source_bucket + '/' + object.key, key: object.key)
    end
  end

  desc 'Save aggregate schools to S3'
  task save_aggregate_schools_to_s3: :environment do
    require 'energy_sparks/s3_yaml'
    target_bucket = ENV['AGGREGATE_SCHOOL_CACHE_BUCKET']
    abort("No S3 bucket configured") if target_bucket.blank?

    School.process_data.order(:name).each do |school|
      Rails.logger.info "Uploading aggregated #{school.name} to S3"
      aggregate_school = AggregateSchoolService.new(school).aggregate_school
      EnergySparks::S3Yaml.save(aggregate_school, school.name, data_type: 'aggregated-meter-collection', bucket: target_bucket)
    rescue StandardError => e
      Rails.logger.error "There was an error for aggregated #{school.name} - #{e.message}"
      Rollbar.error(e, job: :save_aggregate_schools_to_s3, school_id: school.id, school: school.name)
    end
  end

  desc 'Save unvalidated  schools to S3'
  task save_unvalidated_schools_to_s3: :environment do
    require 'energy_sparks/s3_yaml'
    target_bucket = ENV['UNVALIDATED_SCHOOL_CACHE_BUCKET']
    abort("No S3 bucket configured") if target_bucket.blank?
    School.process_data.order(:name).each do |school|

      Rails.logger.info "Uploading unvalidated #{school.name} to S3"
      data = Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated_data
      EnergySparks::S3Yaml.save(data, school.name, data_type: 'unvalidated-data', bucket: target_bucket)
    rescue StandardError => e
      Rails.logger.error "There was an error for unvalidated #{school.name} - #{e.message}"
      Rollbar.error(e, job: :save_unvalidated_schools_to_s3, school_id: school.id, school: school.name)
    end
  end

  desc 'Send custom rollbar reports'
  task custom_rollbar_reports: :environment do
    RollbarNotifierService.new.perform
  end

end
