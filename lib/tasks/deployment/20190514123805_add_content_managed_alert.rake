namespace :after_party do
  desc 'Deployment task: add_content_managed_alert'
  task add_content_managed_alert: :environment do
    puts "Running deploy task 'add_content_managed_alert'"

    analysis = <<~DOC
      This alert is generated every day to provide content-managed alerts.

      Ratings are not required for this alert type as content will always be generated.
    DOC

    AlertType.create!(
      title: 'Content managed',
      class_name: 'Alerts::System::ContentManaged',
      description: 'This alert is generated every day to provide content-managed alerts',
      analysis: analysis,
      has_variables: true,
      has_ratings: false,
      source: :system,
      frequency: :weekly
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190514123805'
  end
end
