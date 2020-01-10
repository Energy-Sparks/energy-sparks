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

      puts "Resetting pupil passwords"
      User.pupil.update_all(pupil_password: nil)
      User.pupil.all.each_with_index do |pupil, index|
        pupil.update!(pupil_password: "pupil#{index}")
      end
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


end
