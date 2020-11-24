namespace :after_party do
  desc 'Deployment task: update_head_teacher_school_summary_to_management_summary'
  task update_head_teacher_school_summary_to_management_summary: :environment do
    puts "Running deploy task 'update_head_teacher_school_summary_to_management_summary'"

    # Put your task implementation HERE.
    AlertType.where(class_name: 'HeadTeachersSchoolSummaryTable').update_all(class_name: 'ManagementSummaryTable')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end