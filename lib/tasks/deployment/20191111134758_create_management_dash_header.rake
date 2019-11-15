namespace :after_party do
  desc 'Deployment task: create_management_dash_header'
  task create_management_dash_header: :environment do
    puts "Running deploy task 'create_management_dash_header'"

    alert_type = AlertType.create!(
      frequency: :weekly,
      title: "Management school summary table",
      class_name: 'HeadTeachersSchoolSummaryTable',
      source: :analytics,
      background: true
    )
    rating = AlertTypeRating.create!(rating_from: 0, rating_to: 10, alert_type: alert_type, management_dashboard_table_active: true, description: 'N/A')
    AlertTypeRatingContentVersion.create!(alert_type_rating: rating)

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
