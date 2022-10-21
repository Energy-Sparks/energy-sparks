namespace :database do
  desc 'manually delete all old database content'
  # Run with:
  # bundle exec rake 'database:content_deletion['31-12-2020']'
  task :content_deletion, [:older_than] => :environment do |_t, args|
    begin
      older_than = Date.parse(args[:older_than], '%Y-%m-%d').end_of_day
      default_older_than = Alerts::ContentDeletionService::DEFAULT_OLDER_THAN

      if older_than > default_older_than
        STDOUT.puts "Warning: Date is less than default (#{default_older_than}). Enter [Y] to continue:"
        input = STDIN.gets.chomp
        if ['Y','y'].include? input
          puts "#{DateTime.now.utc} manually delete all old content start"
          Alerts::ContentDeletionService.new(older_than).delete!
          puts "#{DateTime.now.utc} manually delete all old content end"
        else
          puts 'Ok, cancelling.'
        end
      else
        puts "#{DateTime.now.utc} manually delete all old content start"
        Alerts::ContentDeletionService.new(older_than).delete!
        puts "#{DateTime.now.utc} manually delete all old content end"
      end

    rescue => e
      puts "Exception: running content_deletion: #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      Rails.logger.error "Exception: running content_deletion: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :content_deletion)
    end
    puts "#{DateTime.now.utc} manually delete all old content end"
  end
end