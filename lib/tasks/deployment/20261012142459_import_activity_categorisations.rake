# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: import_activity_categorisations'
  task import_activity_categorisations: :environment do
    puts "Running deploy task 'import_activity_categorisations'"

    file_name = File.join(__dir__, 'activities-categorisations-2026-10-15.csv')

    importer = Tasks::Importer::Activity.new(file_name).run

    puts "Imported categorisations for #{importer.imported_count} activity types"
    puts "Could not find activity types with ids: #{importer.missing_ids.join(', ')}" if importer.missing_ids.any?

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end

  desc 'Rollback task: import_activity_categorisations'
  task rollback_activity_categorisations: :environment do
    puts "Running deploy task 'rollback_activity_categorisations'"

    Tasks::Importer::Activity.rollback

    puts 'Emptied the activity categorisation tables'
  end
end
