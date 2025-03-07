namespace :mailchimp do
  desc "Export new versions of Mailchimp export CSV files"
  task :csv_export, [:dir, :add_defaults] => :environment do |t,args|
    args.with_defaults(add_defaults: false)
    add_defaults = ActiveModel::Type::Boolean.new.cast( args.add_defaults )

    puts "#{DateTime.now.utc} Mailchimp CSV Export Started"
    puts "Loading from #{args.dir}, add_defaults #{add_defaults}"

    audience = {}
    [:subscribed, :unsubscribed, :nonsubscribed, :cleaned].each do |category|
      file = Dir.glob("#{category}*", base: args.dir).first
      audience[category] = CSV.read("#{args.dir}/#{file}", headers: true, header_converters: :symbol)
    end

    service = Mailchimp::CsvExporter.new(add_default_interests: add_defaults, **audience)
    puts "#{DateTime.now.utc} Fetching data"

    service.perform

    puts "#{DateTime.now.utc} Exporting data"

    headers = [
      :email_address,
      :name,
      :locale,
      :contact_source,
      :confirmed_date,
      :user_status,
      :user_role,
      :staff_role,
      :alert_subscriber,
      :school,
      :school_url,
      :school_slug,
      :school_status,
      :school_type,
      :school_group,
      :school_group_url,
      :school_group_slug,
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
