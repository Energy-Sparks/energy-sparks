# rubocop:disable Metrics/BlockLength
namespace :commercial do
  desc 'Import licences from a CSV file.'
  task :import_licences, [:csv_file] => :environment do |_t, args|
    puts "#{DateTime.now.utc} Loading licences from #{args.csv_file}"

    importer = Commercial::LicenceImporter.new
    CSV.foreach(args.csv_file, headers: true) do |row|
      begin
        next if row['Archived?'] == 'TRUE'
        licence = importer.import({
          contract_name: row['Contract name'],
          licence_holder: row['School name'],
          start_date: row['Licence start date'],
          end_date: row['Licence end date'],
          school_specific_price: row['School specific price'],
          status: row['Licence status'],
          comments: row['Notes']
        })
        unless licence.present?
          puts "Unable to import licence for #{row['School name']}"
        end
      rescue => e
        puts row['School name']
        puts e
      end
    end

    puts "#{DateTime.now.utc} Completed licences contracts"
  end
end
# rubocop:enable Metrics/BlockLength
