# frozen_string_literal: true

namespace :tasks do
  namespace :import do
    desc 'Import action classifications from a CSV file'
    task :action_categorisations, [:csv_file] => :environment do |_t, args|
      # Exported on 15/10/2026 from the following spreadsheet:
      # https://docs.google.com/spreadsheets/d/1GmCHb0PFWvaF2_cAaUlLzOyx6vkNPj0ilAiT7JDfugA/edit?usp=sharing

      args.with_defaults(csv_file: File.join(__dir__, 'actions-categorisations-2026-10-15.csv'))

      importer = Tasks::Importer::Action.new(args[:csv_file]).run

      puts "Imported focus labels for #{importer.imported_count} intervention types"
      puts "Could not find intervention types with ids: #{importer.missing_ids.join(', ')}" if importer.missing_ids.any?
    end

    desc 'Rollback action classifications'
    task action_categorisations_rollback: :environment do
      Tasks::Importer::Action.rollback

      puts 'Emptied the action categorisation tables'
    end
  end
end
