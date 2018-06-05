require 'csv'

namespace :alerts do
  desc 'Set up school times'
  task setup: [:environment] do
    puts Time.zone.now
    data_hash = CSV.foreach( 'etc/alerts.csv', headers: true, header_converters: :symbol).select { |row| !row.empty? }.map(&:to_h)
    AlertTypeFactory.new(data_hash).create

    School.enrolled.each do |school|
      AlertType.all.each do |alert_type|
        school.alerts.create(alert_type: alert_type)
      end
    end
   # puts data_hash.class
    puts Time.zone.now
  end
end


