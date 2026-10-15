# frozen_string_literal: true

namespace :tasks do
  namespace :import do
    desc 'Import activity classifications from a CSV file'
    task :activity_categorisations, [:csv_file] => :environment do |_t, args|
      # Exported on 15/10/2026 from the following spreadsheet:
      # https://docs.google.com/spreadsheets/d/1Dzu10e8ljf0flS9SyTAdvdz4MF_2UL6Ed-FidR9VqpQ/edit?usp=sharing

      args.with_defaults(csv_file: File.join(__dir__, 'activities-categorisations-2026-10-15.csv'))

      importer = Tasks::Importer::Activity.new(args[:csv_file]).run

      puts "Imported categorisations for #{importer.imported_count} activity types"
      puts "Could not find activity types with ids: #{importer.missing_ids.join(', ')}" if importer.missing_ids.any?
    end

    desc 'Rollback activity classifications'
    task activity_categorisations_rollback: :environment do
      Tasks::Importer::Activity.rollback

      puts 'Emptied the activity categorisation tables'
    end
  end
end
