namespace :marketing do
  desc "Schools set countries"
  task :mailchimp_csv_export, [:dir] => :environment do |t,args|
    puts "Loading from #{args.dir}"

    audience = {}
    [:subscribed, :unsubscribed, :nonsubscribed, :cleaned].each do |category|
      file = Dir.glob("#{category}*", base: args.dir).first
      audience[category] = CSV.read("#{args.dir}/#{file}", headers: true, header_converters: :symbol)
    end

    service = Marketing::MailchimpCsvExporter.new(**audience)
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
      :school_status,
      :school_group,
      :local_authority,
      :region,
      :country,
      :scoreboard,
      :funder,
      :interests,
      :tags
    ]

    service.updated_audience.each do |category,contacts|
      CSV.open("#{args.dir}/updated-#{category}.csv", "w") do |csv|
        csv << headers
        contacts.each do |contact|
          csv << headers.map { |f| contact[f] }
        end
      end
    end

    CSV.open("#{args.dir}/new-nonsubscribed.csv", "w") do |csv|
      csv << headers
      service.new_nonsubscribed.each do |contact|
        csv << headers.map { |f| contact[f] }
      end
    end

    puts "#{DateTime.now.utc} Mailchimp CSV Export Complete"
  end
end
