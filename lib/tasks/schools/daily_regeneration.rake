namespace :school do
  desc "Schools daily regeneration"
  task daily_regeneration: :environment do
    School.process_data.each do |school|
      DailyRegenerationJob.perform_later(school: school)
    end
  end
end