namespace :commercial do
  desc 'Import licences from a CSV file.'
  task :import_licences, [:csv_file] => :environment do |_t, args|
    puts "#{DateTime.now.utc} Loading licences from #{args.csv_file}"

    importer = Commercial::LicenceImporter.new
    CSV.foreach(args.csv_file, headers: true) do |row|
      licence = importer.import({
        contract_name: data['Contract name'],
        licence_holder: data['School name'],
        start_date: data['Licence start date'],
        end_date: data['Licence end date'],
        school_specific_price: data['School specific price'],
        status: data['Licence status'],
        comments: data['Notes']
      })
      unless licence.present?
        puts "Unable to import licence for #{row['School name']}"
      end
    end

    puts "#{DateTime.now.utc} Completed licences contracts"
  end
end
