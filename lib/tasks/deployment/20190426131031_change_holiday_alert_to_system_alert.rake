namespace :after_party do
  desc 'Deployment task: change_holiday_alert_to_system_alert'
  task change_holiday_alert_to_system_alert: :environment do
    puts "Running deploy task 'change_holiday_alert_to_system_alert'"

    alert_type = AlertType.where(class_name: 'AlertImpendingHoliday').first

    description = <<~DOC
      Alerts on whether a holiday is in the database that has a start date withing the next 7 days.

      If there is no holiday the alert will have a rating of 10 and no values for any of the variables.

      If there is a holiday coming up in the next 7 days the alert will have a rating from 0 to 7, depending on the number of days away it is.

      e.g. if the holiday is coming up in 3 days the holiday will have a rating of 3.0. If it starts today it will have a rating of 0.
    DOC
    alert_type.update!(
      class_name: 'Alerts::System::UpcomingHoliday',
      description: description,
      analysis: '',
      has_variables: true,
      source: :system
    )

    AfterParty::TaskRecord.create version: '20190426131031'
  end
end
