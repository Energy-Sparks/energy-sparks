namespace :mailchimp do
  desc "Export new versions of Mailchimp export CSV files"
  task :csv_export, [:dir] => :environment do |t,args|
    puts "#{DateTime.now.utc} Mailchimp CSV Export Started"
    puts "Loading from #{args.dir}"

    audience = {}
    [:subscribed, :unsubscribed, :nonsubscribed, :cleaned].each do |category|
      file = Dir.glob("#{category}*", base: args.dir).first
      audience[category] = CSV.read("#{args.dir}/#{file}", headers: true, header_converters: :symbol)
    end

    service = Mailchimp::CsvExporter.new(**audience)
    puts "#{DateTime.now.utc} Fetching data"

    service.perform

    puts "#{DateTime.now.utc} Exporting data"

    headers = [
      :email_address,
      :name,
      :locale,
      :contact_source,
      :confirmed_date,
      :user_role,
      :staff_role,
      :alert_subscriber,
      :school,
      :school_url,
      :school_status,
      :school_type,
      :school_group,
      :school_group_url,
      :local_authority,
      :region,
      :country,
      :scoreboard,
      :scoreboard_url,
      :funder,
      :interests,
      :tags
    ]

    service.updated_audience.each do |category,contacts|
      CSV.open("#{args.dir}/updated-#{category}.csv", "w") do |csv|
        csv << headers.map(&:to_s).map(&:humanize)
        contacts.each do |contact|
          csv << headers.map { |f| contact.send(f) }
        end
      end
    end

    CSV.open("#{args.dir}/new-nonsubscribed.csv", "w") do |csv|
      csv << headers.map(&:to_s).map(&:humanize)
      service.new_nonsubscribed.each do |contact|
        csv << headers.map { |f| contact.send(f) }
      end
    end

    puts "#{DateTime.now.utc} Mailchimp CSV Export Complete"
  end
end
