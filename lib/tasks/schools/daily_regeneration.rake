# frozen_string_literal: true

namespace :school do
  desc 'Schools daily regeneration'
  task daily_regeneration: :environment do
    puts "#{DateTime.now.utc} Run daily regeneration for all process data schools start"
    GoodJob::Batch.enqueue(on_finish: DailyRegenerationOnFinishJob) do
      School.process_data.order(:name).each do |school|
        puts "Run daily regeneration job for #{school.name}"
        begin
          DailyRegenerationJob.perform_later(school: school)
        rescue StandardError => e
          EnergySparks::Log.exception(e, job: :daily_regeneration, school_id: school.id, school: school.name)
        end
      end
    end
    puts "#{DateTime.now.utc} Run daily regeneration for all process data schools end"
  end
end
