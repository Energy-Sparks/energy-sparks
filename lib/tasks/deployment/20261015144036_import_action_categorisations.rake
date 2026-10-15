# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: import_action_categorisations'
  task import_action_categorisations: :environment do
    puts "Running deploy task 'import_action_categorisations'"

    file_name = File.join(__dir__, 'actions-categorisations-2026-10-15.csv')

    importer = Tasks::Importer::Action.new(file_name).run

    puts "Imported focus labels for #{importer.imported_count} intervention types"
    puts "Could not find intervention types with ids: #{importer.missing_ids.join(', ')}" if importer.missing_ids.any?

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end

  desc 'Rollback task: import_action_categorisations'
  task rollback_action_categorisations: :environment do
    puts "Running deploy task 'rollback_action_categorisations'"

    Tasks::Importer::Action.rollback

    puts 'Emptied the action categorisation tables'
  end
end
