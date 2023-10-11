namespace :school do
  desc 'Schools set countries'
  task set_countries: :environment do
    puts "#{DateTime.now.utc} Set countries using geocoder.."

    School.all.each do |school|
      school.geocode
      if school.country_changed?
        puts "#{school.name} : country was #{school.country_was}, now #{school.country}"
        school.save!
      end
    end

    puts "#{DateTime.now.utc} Set countries using geocoder end"
  end
end
