namespace :commercial do
  desc 'Import contracts from a CSV file.'
  task :import_contracts, [:csv_file] => :environment do |_t, args|
    puts "#{DateTime.now.utc} Loading contracts from #{args.csv_file}"

    importer = Commercial::ContractImporter.new
    CSV.foreach(args.csv_file, headers: true) do |row|
      contract = importer.import({
        product_name: row['Product name'],
        contract_holder: row['Contract holder'],
        name: row['Contract name'],
        start_date: row['Contract start date'],
        end_date: row['Contract end date'],
        agreed_school_price: row['Agreed per school price'],
        licence_period: row['Licence period'],
        invoice_terms: row['Invoice terms'],
        licence_years: row['Licence years']
      })
      unless contract.present?
        puts "Unable to import contract #{row['Contract name']}"
      end
    end

    puts "#{DateTime.now.utc} Completed loading contracts"
  end
end
