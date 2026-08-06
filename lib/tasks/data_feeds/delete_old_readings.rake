# frozen_string_literal: true

namespace :data_feeds do
  desc 'Remove old, unused data feed readings, import logs and caches of manually uploaded data'
  task delete_old_readings: :environment do
    puts "#{DateTime.now.utc} delete_old_readings start"
    AmrDataFeedReading.delete_old_readings!
    AmrUploadedReading.delete_old_readings!
    puts "#{DateTime.now.utc} delete_old_readings end"
  end
end
