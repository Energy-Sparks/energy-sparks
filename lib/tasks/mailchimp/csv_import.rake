namespace :mailchimp do
  desc "Import data from Mailchimp audience export CSV files"
  task :csv_import, [:dir] => :environment do |t,args|
    puts "#{DateTime.now.utc} Mailchimp CSV Import Started"
    puts "Loading from #{args.dir}"

    audience = {}
    [:subscribed, :unsubscribed, :nonsubscribed, :cleaned].each do |category|
      file = Dir.glob("#{category}*", base: args.dir).first
      audience[category] = CSV.read("#{args.dir}/#{file}", headers: true, header_converters: :symbol)
    end

    service = Mailchimp::CsvImporter.new(**audience)

    service.perform

    puts "#{DateTime.now.utc} Mailchimp CSV Import Complete"
  end
end
