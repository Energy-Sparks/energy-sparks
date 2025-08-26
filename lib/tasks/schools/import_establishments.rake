namespace :school do
  desc 'Import establishment data after school:download_gias_data'
  task :import_establishments, [:path] => :environment do |_t, args|
    args.with_defaults(path: './tmp/gias_download.zip', batch_size: 5000)

    puts 'Importing establishments...'
    Lists::Establishment.import_from_zip(args[:path], args[:batch_size])

    puts 'Importing establishment links...'
    Lists::EstablishmentLink.import_from_zip(args[:path], args[:batch_size])
  end
end
