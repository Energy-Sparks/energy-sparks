require 'csv'

namespace :alerts do
  desc 'Set up school times'
  task setup: [:environment] do
    puts Time.zone.now
    data_hash = CSV.foreach('etc/alerts.csv', headers: true, header_converters: :symbol).select { |row| !row.empty? }.map(&:to_h)
    AlertTypeFactory.new(data_hash).create

    School.enrolled.each do |school|
      Contact.where(school: school, name: 'Will', email_address: 'will@example.com').first_or_create
      Contact.where(school: school, name: 'Harry', email_address: 'harry@example.com').first_or_create

      if school.alerts.empty?
        AlertType.all.each do |alert_type|
          school.alerts.create(alert_type: alert_type)
        end
      end
    end
   # puts data_hash.class
    puts Time.zone.now
  end
end
