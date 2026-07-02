# frozen_string_literal: true

namespace :meters do
  desc 'Import suppliers and data sources from a CSV file.'
  task :import_suppliers_data_sources_and_statuses, [:csv_file] => :environment do |_t, args|
    puts "#{DateTime.now.utc} Loading suppliers and data sources from #{args.csv_file}"

    importer = Meters::SupplierDataSourceStatusImporter.new
    CSV.foreach(args.csv_file, headers: true) do |row|
      meter = importer.import({
                                meter: row['Meter'],
                                data_source: row['Updated Data Source'],
                                supplier: row['Supplier'],
                                status: row['Updated Meter Status']
                              })
      puts "Could not find meter #{row['Meter']}" if meter.blank?
    rescue => e # rubocop:disable Style/RescueStandardError
      puts row['Meter']
      puts e
    end
    puts "#{DateTime.now.utc} Completed import"
  end
end
