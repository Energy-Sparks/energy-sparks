namespace :after_party do
  desc 'Deployment task: mark_complete_programmes'
  task mark_complete_programmes: :environment do
    puts "Running deploy task 'mark_complete_programmes'"

    programmes = Programme.where(id: ProgrammeActivity.all.distinct(:programme_id).pluck(:programme_id)).where.not(status: 'completed')

    programmes.each do |programme|
      # Complete programme if all activity types for the programme type are in the list of completed  activities
      # (extra completed activities are ignored - activity types may have been removed from programme..)
      # Code copied from ActivityCreator#completed_programme?
      programme_type_activity_ids = programme.programme_type.activity_types.pluck(:id)
      programme_activity_types = programme.activities.map(&:activity_type).pluck(:id)

      next unless (programme_type_activity_ids - programme_activity_types).empty?

      programme.complete! unless programme.completed?
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
