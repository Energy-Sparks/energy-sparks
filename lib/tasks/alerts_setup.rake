require 'csv'

namespace :alerts do
  desc 'Set up school times'
  task setup: [:environment] do
    puts Time.zone.now
    data_hash = CSV.foreach('etc/alerts.csv', headers: true, header_converters: :symbol).select { |row| !row.empty? }.map(&:to_h)
    AlertTypeFactory.new(data_hash).create

    School.all.each do |school|
      SchoolCreator.new(school).add_all_alert_types
    end
    # puts data_hash.class
    puts "We now have #{AlertType.count} alert types"
    puts "We now have #{Alert.count} alerts"
    puts Time.zone.now
  end
end
